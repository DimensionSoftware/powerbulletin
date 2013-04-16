window.__  = require \lodash
window.ioc = require './io_client'

global <<< require './pb_helpers'
global <<< require('prelude-ls/prelude-browser-min').prelude

# XXX client-side entry

# shortcuts
$w = $ window
$d = $ document

left-offset = 50px

#{{{ UI Interactions
# ui save state
sep = \-
window.save-ui = -> # serealize ui state to cookie
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
window.load-ui = -> # restore ui state from cookie
  s  = ($.cookie \s)
  $l = $ '#left_content'
  if s
    [searching, collapsed, w] = s.split sep
    w = parseInt w
    $l.transition({width:w}, 500ms, \easeOutExpo -> # restore
      $l.toggle-class \wide ($l.width! > 300px))    # ..left nav
    set-timeout (-> # ... & snap
      $ '#main_content .resizable' .transition({padding-left:w + left-offset}, 450ms, \snap)), 200ms
  if searching is '1' then $ \body .add-class(\searching)
  if collapsed is '1' then $ \body .add-class(\collapsed)
  set-timeout align-breadcrumb, 500ms

# handle
$d.on \click '#handle' ->
  $l = $ '#left_content'
  $ \body .toggle-class \collapsed
  $ '#main_content .resizable'
    .css('padding-left', ($l.width! + left-offset))
  save-ui!

# waypoints
$w.resize (__.debounce (-> $.waypoints \refresh; align-breadcrumb!), 800ms)

# main menu
#$d.on \click 'html.homepage header .menu a.title' ->
#  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html header .menu a.title' window.mutate

# header expansion
$d.on \click 'header' (e) ->
  $ \body .remove-class \searching if e.target.class-name.index-of(\toggler) > -1 # guard
  $ '#query' .focus!
  save-ui!
$d.on \keypress '#query' -> $ \body .add-class \searching; save-ui!

# show reply ui
append-reply-ui = ->
  # find post div
  $p = $ this .parents('.post:first')

  # append dom for reply ui
  unless $p.find('.post-edit:visible').length
    render-and-append window,  $p.find('.reply:first'), \_post_edit, (post:
      method:     \post
      forum_id:   active-forum-id
      parent_id:  $p.data 'post-id'
      is_comment: true), ->
        $p.find('textarea[name="body"]').focus!
  else
    $p.find('.cancel').click!

censor = ->
  # find post div
  $p = $(this).parents('.post:first')
  post-id = $p.data('post-id')

  $.post "/resources/posts/#{post-id}/censor", (r) ->
    if r.success
      $p.transition { opacity: 0, scale: 0.3 }, 300s, \in, ->
        $p.hide!
    else
      console.warn r.errors.join(', ')
#}}}

#.
#### main   ###############>======-- -   -
##
if window.location.hash is \#validate then after-login! # email activation
load-ui!
$ '#query' .focus!

#{{{ Delegated Events
# generic form-handling ui
$d.on \click '.create .no-surf' require-login(->
  $ '#main_content .forum' .html '' # clear canvas
  edit-post is-editing(window.location.pathname), forum_id:window.active-forum-id)
$d.on \click '.edit.no-surf' require-login(-> edit-post is-editing(window.location.pathname))
$d.on \click '.onclick-submit .cancel' ->
  f = $ this .closest '.post-edit'  # form
  f.hide 350ms \easeOutExpo
  remove-editing-url!
$d.on \click '.onclick-submit input[type="submit"]' require-login(
  (e) -> submit-form(e, (data) ->
    f = $ this .closest(\.post-edit) # form
    p = f .closest(\.editing)        # post being edited
    # render updated post
    p.find '.title' .html(data.0?title)
    p.find '.body'  .html(data.0?body)
    f.remove-class \fadein .hide(300s) # & hide
    remove-editing-url!
    false))

$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)
$d.on \click '.onclick-censor-post' require-login(censor)

# login delegated events
window.switch-and-focus = (remove, add, focus-on) ->
  $e = $ '.fancybox-wrap'
  $e.remove-class("#remove shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10ms
$d.on \click '.onclick-close' ->
  $.fancybox.close!
$d.on \click '.onclick-show-login' ->
  switch-and-focus 'on-forgot on-register' \on-login '#auth input[name=username]'
$d.on \click '.onclick-show-forgot' ->
  switch-and-focus \on-error \on-forgot '#auth input[name=email]'
$d.on \click '.onclick-show-choose' ->
  switch-and-focus \on-login \on-choose '#auth input[name=username]'
$d.on \click '.onclick-show-register' ->
  switch-and-focus \on-login \on-register '#auth input[name=username]'

# catch esc key events on input boxes for login box
$d.on \keyup '.fancybox-inner input' ->
  if it.which is 27 # enter key
    $.fancybox.close!
    return false
#}}}

window.has-mutated-forum = window.active-forum-id

if mocha? and window.location.search.match /test=1/
  cleanup-output = ->
    $('body > *:not(#mocha)').remove!

    # mocha style (JUST IN TIME!)
    mocha-css-el =
      $("<link rel=\"stylesheet\" type=\"text/css\" href=\"#{window.cache_url}/local/mocha.css\">")
    $('head').append(mocha-css-el)

  mocha.setup \bdd

  # actual tests
  $.get-script "#{window.cache_url}/tests/test1.js", ->
    run = ->
      mocha.run cleanup-output
    set-timeout run, 2000 # gotta give time for tests to load


# vim:fdm=marker
