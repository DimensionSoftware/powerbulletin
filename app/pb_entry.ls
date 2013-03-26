window.__  = require \lodash
window.ioc = require './io_client'

global <<< require './pb_helpers'

# XXX client-side entry

# shortcuts
$w = $ window
$d = $ document

#{{{ UI Interactions
# save state
sep    = \-
offset = 20px
window.save-ui = ->
  min-width = 200px
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
    w = (parseInt w) + 20px
    $l.transition({width:w}, 500ms, 'easeOutExpo' -> # restore left nav
      $l.toggle-class \wide ($l.width! > 300px))
    set-timeout (-> # ... & snap
      $ '#main_content.container .forum' .transition({padding-left:w}, 450ms, \snap)), 200ms
  if searching is not '0' then $ \body .add-class(\searching)
  if collapsed is not '0' then $ \body .add-class(\collapsed)
  set-timeout align-breadcrumb, 500ms

# handle
$d.on \click '#handle' ->
  $l = $ '#left_content'
  $ \body .toggle-class \collapsed
  $ '#main_content.container .forum'
    .css('padding-left', ($l.width! + offset))
  save-ui!

# waypoints
$w.resize -> set-timeout (-> $.waypoints \refresh), 800ms
set-timeout (-> # sort control
  $ '#sort li' .waypoint {
    context: \ul
    offset : 30px
    handler: (direction) ->
      e = $ this # figure active element
      if direction is \up
        e := e.prev!
      e := $ this unless e.length

      $ '#sort li.active' .remove-class \active
      e .add-class \active # set!
  }), 100ms

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
  setTimeout (-> $ '#auth input[name=username]' .focus! ), 100ms

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
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100ms
  false

# get the user after a successful login
window.after-login = ->
  window.user <- $.getJSON '/auth/user'
  window.mutants?[window.mutator]?.on-personalize window, user, ->
    socket?disconnect()
    socket?socket?connect()

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
      $.fancybox.close!
      $form.find("input:text,input:password").remove-class(\validation-error).val ''
      after-login!
    else
      r.errors?.for-each (e) ->
        $form.find("input[name=#{e.param}]").add-class \validation-error .focus!
      $fancybox = $form.parents('.fancybox-wrap:first') .remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake)), 100ms
  return false

$d.on \submit '.login form' login
$d.on \submit '.register form' register
#}}}

#.
#### main   ###############>======-- -   -
##
load-ui!
$ '#query' .focus!

# for general form submission
submit-form = (event, fn) ->
  $f = $ event.target .closest(\form) # get event's form
  $.ajax {
    url:      $f.attr(\action)
    type:     $f.attr(\method)
    data:     $f.serialize!
    data-type: \json
    success:  (data) ->
      if fn then fn.call $f, data}
  false

# show reply ui
append-reply-ui = ->
  # find post div
  $p = $ this .parents('.subpost:first')
  unless $p.length
    $p = $ this .parents('.post:first')

  # append dom for reply ui
  if $p.find('.reply form').length is 0
    $p.find('.reply:first').append jade.templates.post_edit post:
      method:     \post
      forum_id:   active-forum-id
      parent_id:  $p.data 'post-id'
      is_comment: true
  else
    $p.find('.reply:first form').remove!
  $p.find('textarea[name="body"]').focus!

censor = ->
  # find post div
  $subpost = $(this).parents('.subpost:first')
  unless $subpost.length
    $subpost = $(this).parents('.post:first')
  post-id  = $subpost.data('post-id')

  $.post "/resources/posts/#{post-id}/censor", (r) ->
    if r.success
      $subpost.transition { opacity: 0, scale: 0.3 }, 300s, 'in', ->
        $subpost.hide!
    else
      console.warn r.errors.join(', ')

#{{{ Delegated Events
# TODO new post

# generic form-handling ui
$d.on \click '.edit.no-surf' require-login(-> edit-post is-editing!)
$d.on \click '.onclick-submit .cancel' ->
  f = $ this .closest '.container'  # form
  f.remove-class \fadein .hide 300s # & hide
$d.on \click '.onclick-submit input[type="submit"]' require-login(
  (e) -> submit-form(e, (data) ->
    f = $ this .closest('.container') # form
    p = f .closest('.editing')        # post being edited
    # render updated post
    p.find '.title' .html(data.0?title)
    p.find '.body'  .html(data.0?body)
    f.remove-class \fadein .hide(300s) # & hide
    History.push-state {no-surf:true} '' window.location.href.replace(/\/edit\/[\/\d+]+$/, '')
    false))

$d.on \click '.require-login' require-login(-> this.click)
$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)
$d.on \click '.onclick-censor-post' require-login(censor)

# login delegated events
window.switch-and-focus = (e, remove, add, focus-on) ->
  $e = $ e
  $e .remove-class("#{remove} shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10ms
$d.on \click '.onclick-show-login' ->
  switch-and-focus '.fancybox-wrap' 'on-forgot on-register' \on-login '#auth input[name=username]'
$d.on \click '.onclick-show-forgot' ->
  switch-and-focus '.fancybox-wrap' \on-error \on-forgot '#auth input[name=email]'
$d.on \click '.onclick-show-choose' ->
  switch-and-focus '.fancybox-wrap' \on-login \on-choose '#auth input[name=username]'
$d.on \click '.onclick-show-register' ->
  switch-and-focus '.fancybox-wrap' \on-login \on-register '#auth input[name=username]'

# catch esc key events on input boxes for login box
$d.on \keyup '.fancybox-inner input' ->
  if it.which is 27 # enter key
    $.fancybox.close!
    return false
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
  if at-bottom! and window.lv and window.page < window.pages-count
    window.page = window.page + 1 # increment page for next operation
    el = window.lv.append "<div data-page=\"#{window.page}\"/>"

toggle-page = (num) ->
  $ '#paginator .page' .remove-class \active
  $ "\#paginator .page:contains(#{num})" .add-class \active

track-pages = ->
  current-top = $w.scroll-top! + $w.height!
  pages = []

  $('[data-page]').each ->
    $el = $(this)
    top = $el.position().top
    dist = Math.abs(current-top - top)
    pages.push {$el, top, dist}

  # choose page with lowest 
  if pages.length
    closest = pages.reduce (p1, p2) ->
      if p1.dist > p2.dist
        p2
      else
        p1

    cur-page = closest.$el.data \page
    toggle-page cur-page

#track-pages = ->
  # tops is the list of tops for
  # beppus fun: c is current position
  #function page(c, tops) { return 1 + tops.indexOf(__.find(tops, function(t){ return t > c })) }

$(window).scroll __.debounce(infinity-load-more-placeholders, 25ms)
$(window).scroll __.debounce(track-pages, 50ms)

window.has-mutated-forum = window.active-forum-id
# vim:fdm=marker
