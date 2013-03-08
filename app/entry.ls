
# XXX client-side entry

# shortcuts
$w = $ window
$d = $ document

#{{{ UI Interactions
# save state
sep = \-
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
  $.cookie \s, vals.join(sep)
window.load-ui = ->
  s = ($.cookie \s)
  if s
    [searching, collapsed, w] = s.split sep
    $ '#left_content' .width(parseInt(w)+20)
  if searching is not '0' then $ \body .add-class(\searching)
  if collapsed is not '0' then $ \body .add-class(\collapsed)

# handle
$d.on \click '#handle' ->
  $ \body .toggle-class \collapsed
  $ '#main_content.container .forum'
    .css('padding-left', ($ '#left_content' .width! + 20))
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

# login action
login = ->
  $form = $(this)
  u = $form.find('input[name=username]')
  p = $form.find('input[name=password]')
  params =
    username: u.val!
    password: p.val!
  $.post $form.attr(\action), params, (r) ->
    if r.success
      window.location.reload!
      # XXX - need to make this not require a reload
      # window.user = r.user
      # XXX - then emit an event to let various client-side systems know that we're logged in now
    else
      $fancybox = $form.parents('.fancybox-wrap:first')
      $fancybox.add-class \on-error
      $fancybox.remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100
  return false

# require that window.user exists before calling fn
require-login = (fn) ->
  ->
    if window.user
      fn.apply this, arguments
    else
      show-login-dialog!
      false
$d.on \submit '.login form' login
#}}}

#.
#### main   ###############>======-- -   -
##
load-ui!
$ '#query' .focus!

add-post-dialog = ->
  query =
    fid: window.active-forum-id
  html <- $.get '/resources/posts', query
  $.fancybox(html)
  false # stop event propagation

# assumes immediate parent is form (in case of submit button)
add-post = ->
  form = $ '#add-post-form'
  $.post '/resources/posts', form.serialize!, (_r1, _r2, res) ->
    console.log 'success! post added', res
    console.log 'stub: do something fancy to confirm submission'
  false # stop event propagation

# show reply ui
append-reply-ui = ->
  # find post div
  $subpost = $(this).parents('.post:first')
  unless $subpost.length
    $subpost = $(this).parents('.subpost:first')
  post-id  = $subpost.data('post-id')

  # FIXME html 
  reply-ui-html = """
  <form method="post" action="/resources/posts">
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
  $subpost = $(this).parents('.post:first')
  unless $subpost.length
    $subpost = $(this).parents('.subpost:first')

  console.log $subpost.text!
  post_id  = $subpost.data('post-id')
  $.post "/resources/posts/#{post_id}/censor", (r) ->
    if r.success
      console.log "censored post ##{post_id}"
      $subpost.transition { opacity: 0, scale: 0.3 }, 300, 'in', ->
        $subpost.hide!
    else
      console.warn r.errors.join(', ')

# delegated events
$d.on \click '#add-post-submit' require-login(add-post)
$d.on \click '.onclick-add-post-dialog' add-post-dialog
$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)
$d.on \click '.onclick-censor-post' require-login(censor)

# login delegated events
switch-and-focus = (e, remove, add, focus-on) ->
  $e = $ e
  $e .remove-class("#{remove} shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10
$d.on \click '.onclick-show-login' ->
  switch-and-focus '.fancybox-wrap' \on-forgot \on-login '#auth input[name=username]'
$d.on \click '.onclick-show-forgot' ->
  switch-and-focus '.fancybox-wrap' \on-error \on-forgot '#auth input[name=email]'
$d.on \click '.onclick-show-choose' -> # XXX beppusan-- renders the dialog for choosing a username
  switch-and-focus '.fancybox-wrap' \on-login \on-choose '#auth input[name=username]'

window.has-mutated-forum = window.active-forum-id
# vim:fdm=marker
