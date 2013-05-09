window.__    = require \lodash
window.ioc   = require \./io-client
window.Pager = require \./pager
window.furl  = require \./forum-urls

global <<< require \./pb-helpers
global <<< require(\prelude-ls/prelude-browser-min).prelude

# XXX client-side entry
# shortcuts
$w = $ window
$d = $ document

left-offset = 50px

#{{{ UI Interactions
# ui save state
sep = \-
window.save-ui = -> # serialize ui state to cookie
  min-width = 200px
  w = $ \#left_content .width!
  s = $.cookie \s
  if s then [_, _, prev] = s.split sep
  w = if w > min-width then w else prev or min-width # default
  vals =
    if $ \body .has-class(\collapsed) then 1 else 0
    w
  $.cookie \s, vals.join(sep),
    path:   \/
    secure: true
window.load-ui = -> # restore ui state from cookie
  s  = $.cookie \s
  $l = $ \#left_content

  set-wide = -> $l.toggle-class \wide ($l.width! > 300px)

  if s # restore
    [collapsed, w] = s.split sep
    if collapsed is \1 and not $ \html .has-class \admin
      $ \body .add-class \collapsed # only collapse on non-admin mutants
    w = parse-int w
    $l.transition({width: w} 500ms \easeOutExpo -> set-wide!)
    set-timeout (-> # ... & snap
      $ '#main_content .resizable' .transition({padding-left: w+left-offset} 450ms \snap)), 300ms
  else # default
    set-wide!
  set-timeout align-breadcrumb, 500ms

# waypoints
$w.resize (__.debounce (-> $.waypoints \refresh; respond-resize!; align-breadcrumb!), 800ms)

# show reply ui
append-reply-ui = (e) ->
  # find post div
  $p = $ this .parents(\.post:first)

  # append dom for reply ui
  unless $p.find('.reply .post-edit:visible').length
    render-and-append window,  $p.find(\.reply:first), \post-edit, (post:
      method:     \post
      forum_id:   $p.data(\forum-id) or window.active-forum-id
      parent_id:  $p.data \post-id
      is_comment: true), ->
        if e.original-event then $p.find('textarea[name="body"]').focus! # user clicked
  else
    $p.find('.reply .cancel').click!

censor = ->
  # find post div
  $p = $(this).parents(\.post:first)
  post-id = $p.data(\post-id)

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
$ \#query .focus!

# Delegated Events
#{{{ - search and ui delegated events
# window.ui is the object which will receive events and have events triggered on it
window.$ui = $ {}

# keys that actually trigger the search
$d.on \keyup, \#query, __.debounce((->
  # ignore special keys & delete when search is empty
  unless it.which in [13 16 17 18 20 27 32 37 38 39 40 87 91 93 188] or (it.which is 8 and !it.target.value.length)
    console.log "#{it.which} triggered search"
    $ui.trigger \search, {q: $(@).val!}
  true), 250ms)
$ui.on \search, (e, searchopts) ->
  uri = "/search?#{$.param searchopts}"
  #XXX: searchopts should move into socket.io, instead of just q
  socket.emit \search searchopts.q
  History.push-state {searchopts}, '', uri

$ui.on \thread-create, (e, thread) ->
  console.info 'thread-create', thread
  <- render-and-prepend window,  $('#left_container .threads'), \thread, thread:thread
  $ '#left_container .threads div.fadein li' .unwrap!

$ui.on \nav-top-posts, (e, threads) ->
  console.info \stub, threads

#}}}

#{{{ - login delegated events
window.switch-and-focus = (remove, add, focus-on) ->
  $e = $ \.fancybox-wrap
  $e.remove-class("#remove shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10ms
$d.on \click \.onclick-close ->
  $.fancybox.close!
$d.on \click \.onclick-show-login ->
  switch-and-focus 'on-forgot on-register on-reset' \on-login '#auth input[name=username]'
$d.on \click \.onclick-show-forgot ->
  switch-and-focus \on-error \on-forgot '#auth input[name=email]'
$d.on \click \.onclick-show-choose ->
  switch-and-focus \on-login \on-choose '#auth input[name=username]'
$d.on \click \.onclick-show-register ->
  switch-and-focus \on-login \on-register '#auth input[name=username]'

# catch esc key events on input boxes for login box
$d.on \keyup '.fancybox-inner input' ->
  if it.which is 27 # esc
    $.fancybox.close!
    false
#}}}
#{{{ - header (main menu)
#$d.on \click 'html.homepage header .menu a.title' ->
#  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html header .menu a.title' window.mutate

# search header
$d.on \click 'header .close' (e) ->
  $ \#query .focus!
  History.back!
#{{{ - left_nav handle
$d.on \click \#handle ->
  $l = $ \#left_content
  $ \body .toggle-class \collapsed
  $ '#main_content .resizable'
    .css(\padding-left, ($l.width! + left-offset))
  save-ui!
#}}}

# {{{ Mocha testing harness
if mocha? and window.location.search.match /test=1/
  cleanup-output = ->
    $('body > *:not(#mocha)').remove!
    mocha-css-el = # mocha style (JUST IN TIME!)
      $("<link rel=\"stylesheet\" type=\"text/css\" href=\"#{window.cache-url}/local/mocha.css\">")
    $ \head .append(mocha-css-el)

  mocha.setup \bdd

  # actual tests
  $.get-script "#{window.cache-url}/tests/test1.js", ->
    run = ->
      mocha.run cleanup-output
    set-timeout run, 2000ms # gotta give time for tests to load
#}}}
#}}}
#{{{ - admin
$d.on \click  'html.admin .onclick-submit input[type="submit"]' require-login(submit-form)
$d.on \change 'html.admin .domain' -> # set keys
  id = parse-int($ '.domain option:selected' .val!)
  domain = find (.id is id), site.domains
  for k in [
    \facebookClientId
    \facebookClientSecret
    \twitterConsumerKey
    \twitterConsumerSecret
    \googleConsumerKey
    \googleConsumerSecret]
      $ "[name='#k']" .val domain.config[k]
#}}}
#
# vim:fdm=marker
