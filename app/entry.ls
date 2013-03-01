
# XXX client-side entry for homepage & forum mutants

# shortcuts
$w = $ window
$d = $ document

window.mutants = require './mutants'

#{{{ UI Interactions
# save state
sep = \-
window.save-ui = ->
  w = $ '#left_content' .width!
  s = ($.cookie \s)
  if s then [_, _, prev] = s.split sep
  w = if w > 30 then w else prev or 200 # default
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
$ '#handle' .on \click -> $ \body .toggle-class \collapsed; save-ui!

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
  $(html).dialog modal: true
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

# delegated events
$d.on \click '#add-post-submit' require-login(add-post)
$d.on \click '.onclick-add-post-dialog' add-post-dialog
$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)

# personalization ( based on parameters from user obj )
window.user <- $.getJSON '/auth/user'

# run initial mutant
window.mutant.run window.mutants[window.initial-mutant], {initial: true, window.user}

# vim:fdm=marker
