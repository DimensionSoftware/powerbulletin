window.__ = require \lodash
window.ioc = require './io_client'

# XXX client-side entry

# shortcuts
$w = $ window
$d = $ document

#{{{ UI Interactions
# save state
sep    = \-
offset = 20
window.save-ui = ->
  min-width = 200
  w = $ '#left_content' .width!
  s = ($.cookie \s)
  if s then [_, _, prev] = s.split sep
  w = if w > min-width then w else prev or min-width # default
  vals =
    if $ \body .has-class(\searching) then 1 else 0
    if $ \body .has-class(\collapsed) then 1 else 0
    w
  $.cookie \s, vals.join(sep),
    path: '/'
window.load-ui = ->
  s  = ($.cookie \s)
  $l = $ '#left_content'
  if s
    [searching, collapsed, w] = s.split sep
    w = parseInt w
    $l.transition({width:w}, 500, 'easeOutExpo' -> # restore left nav
      $l.toggle-class \narrow ($l.width! < 300))
    set-timeout (-> # ... & snap
      $ '#main_content.container .forum' .transition({padding-left:w}, 450, \snap)), 200
  if searching is not '0' then $ \body .add-class(\searching)
  if collapsed is not '0' then $ \body .add-class(\collapsed)

window.align-breadcrumb = ->
  $ '.breadcrumb.stuck' .css(\left, $('#left_content').width! + offset)

# handle
$d.on \click '#handle' ->
  $l = $ '#left_content'
  $ \body .toggle-class \collapsed
  $ '#main_content.container .forum'
    .css('padding-left', ($l.width! + offset))
  align-breadcrumb!
  save-ui!

# waypoints
$w.resize -> set-timeout (-> $.waypoints \refresh), 800
set-timeout (-> # sort control
  $ '#sort li' .waypoint {
    context: \ul
    offset : 30
    handler: (direction) ->
      e = $ this # figure active element
      if direction is \up
        e := e.prev!
      e := $ this unless e.length

      $ '#sort li.active' .remove-class \active
      e .add-class \active # set!
  }), 100

# main menu
$d.on \click 'html.homepage header .menu a.title' ->
  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html.forum header .menu a.title' window.mutate

# header expansion
$d.on \click 'header' (e) ->
  $ \body .remove-class \searching if e.target.class-name.index-of(\toggler) > -1 # guard
  $ '#query' .focus!
  save-ui!
$d.on \keypress '#query' -> $ \body .add-class \searching; save-ui!
#}}}
#{{{ Login
show-login-dialog = ->
  $.fancybox.open '#auth'
  setTimeout (-> $ '#auth input[name=username]' .focus! ), 100

# require that window.user exists before calling fn
require-login = (fn) ->
  ->
    if window.user
      fn.apply this, arguments
    else
      show-login-dialog!
      false

# register action
# login action
window.login = ->
  $form = $(this)
  u = $form.find('input[name=username]')
  p = $form.find('input[name=password]')
  console.log \login
  params =
    username: u.val!
    password: p.val!
  $.post $form.attr(\action), params, (r) ->
    if r.success
      $.fancybox.close!
      after-login!
    else
      $fancybox = $form.parents('.fancybox-wrap:first')
      $fancybox.add-class \on-error
      $fancybox.remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100
  false

# get the user after a successful login
window.after-login = ->
  window.user <- $.getJSON '/auth/user'
  console.info 'logged in as:', window.user
  window.mutants?[window.mutator]?.on-personalize window, user, ->

# logout
window.logout = ->
  r <- $.get '/auth/logout'
  window.location.reload!

# register
window.register = ->
  $form = $(this)
  $form.find("input").remove-class \validation-error
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      console.warn \success
      $.fancybox.close!
      $form.find("input:text,input:password").remove-class(\validation-error).val ''
      after-login!
    else
      console.warn 'display errors', r
      r.errors?.for-each (e) ->
        $form.find("input[name=#{e.param}]").add-class \validation-error .focus!
      $fancybox = $form.parents('.fancybox-wrap:first') .remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake)), 100
  return false

$d.on \submit '.login form' login
$d.on \submit '.register form' register
#}}}

#.
#### main   ###############>======-- -   -
##
align-breadcrumb!
load-ui!
$ '#query' .focus!

# assumes immediate parent is form (in case of submit button)
submit-form = ->
  # TODO guard
  $f = $ this .closest(\form)

  # TODO use $.ajax
  $.ajax $f.attr(\action), {
    type:$f.attr(\method)
    data:$f.serialize!
    success: (data, _r2, res) ->
      # TODO -- render jade post on client side with from-server json objects
      console.log data
      $f.hide 300
  }
  false

# show reply ui
append-reply-ui = ->
  # find post div
  $subpost = $(this).parents('.subpost:first')
  unless $subpost.length
    $subpost = $(this).parents('.post:first')
  post-id  = $subpost.data('post-id')

  # FIXME html -- move to clientJade
  reply-ui-html = """
  <form id="add_reply_submit" method="post" action="/resources/posts">
    <textarea name="body"></textarea>
    <input type="hidden" name="forum_id" value="#{window.active-forum-id}">
    <input type="hidden" name="parent_id" value="#{post-id}">
    <div>
      <input type="submit" value="Post">
    </div>
  </form>
  """
  # append dom for reply ui
  if $subpost.find('.reply form').length is 0
    $subpost.find('.reply:first').append reply-ui-html
  else
    $subpost.find('.reply:first form').remove!

censor = ->
  # find post div
  $subpost = $(this).parents('.subpost:first')
  unless $subpost.length
    $subpost = $(this).parents('.post:first')
  post-id  = $subpost.data('post-id')

  $.post "/resources/posts/#{post-id}/censor", (r) ->
    if r.success
      $subpost.transition { opacity: 0, scale: 0.3 }, 300, 'in', ->
        $subpost.hide!
    else
      console.warn r.errors.join(', ')

#{{{ Delegated Events
#$d.on \click '#add_post_submit' require-login(submit-form)
$d.on \click '#edit_post_form input[type="submit"]' require-login(submit-form)
$d.on \click '#add_reply_submit input[type="submit"]' require-login(submit-form)
$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)
$d.on \click '.onclick-censor-post' require-login(censor)

# login delegated events
window.switch-and-focus = (e, remove, add, focus-on) ->
  $e = $ e
  $e .remove-class("#{remove} shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10
$d.on \click '.onclick-show-login' ->
  switch-and-focus '.fancybox-wrap' 'on-forgot on-register' \on-login '#auth input[name=username]'
$d.on \click '.onclick-show-forgot' ->
  switch-and-focus '.fancybox-wrap' \on-error \on-forgot '#auth input[name=email]'
$d.on \click '.onclick-show-choose' ->
  switch-and-focus '.fancybox-wrap' \on-login \on-choose '#auth input[name=username]'
$d.on \click '.onclick-show-register' ->
  switch-and-focus '.fancybox-wrap' \on-login \on-register '#auth input[name=username]'
#}}}

at-bottom = (pct-threshold = 0.7) ->
  # thx, stack overflow guy:
  # http://stackoverflow.com/a/12279215
  # I super distilled it though... and added a threshold
  # and... more heuristics
  [st, wh, dh] = [$w.scroll-top!, $w.height!, $d.height!]

  # represents roughly the percentage scrolled down in window
  rough-scroll-percent = (wh + st) / dh

  # additional debug annotations
  #console.log {st, wh, dh}
  #console.log {wh-plus-st: wh + st, rough-scroll-percent}

  # Not at the top of the page
  #      | We're definitely at the end, motherfucker
  #      |                   |     
  #      |                   | Alternatively, the boss (programmer) said we are at the end, motherfucker
  #      |                   |                                         |
  #      \/                  \/                                        \/
  (st > 0) && ((wh + st >= dh) || (rough-scroll-percent > pct-threshold))

# infinity scroll -- function to add placeholders divs for pages
# TODO: calculate actual number of pages to be appended (there is a max)
infinity-load-more-placeholders = ->
  if at-bottom! and window.lv
    window.page = window.page + 1 # increment page for next operation
    window.lv.append "<div data-page=\"#{window.page}\">Placeholder Page ##{window.page}</div>"

# TODO: debounce with lodash
$(window).scroll __.debounce(infinity-load-more-placeholders, 25)

# this is always chuggin along ; )
# just in case scroll events fail to pre-emptively load
#set-interval infinity-load-more, 500

window.has-mutated-forum = window.active-forum-id
# vim:fdm=marker
