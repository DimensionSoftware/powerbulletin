
window.__    = require \lodash
window.ioc   = require \./io-client.ls
window.Chat  = require \../component/Chat.ls
window.Pager = require \./pager.ls
window.furl  = require \./forum-urls.ls
window.tasks = require \./tasks.ls

global <<< require \./pb-helpers.ls
global <<< require(\prelude-ls/prelude-browser-min) \prelude-ls

require! ch: \./client-helpers.ls

# components
require! \../component/Buy.ls

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
      $l.find \.scrollable .get-nice-scroll!resize!
    w = parse-int w
    $l.transition({width: w} 500ms \easeOutExpo -> set-wide!)
    set-timeout (-> # ... & snap
      $ '#main_content .resizable' .transition({padding-left: w+left-offset} 450ms \snap)), 300ms
  set-timeout (-> set-wide!; align-breadcrumb!), 500ms

# waypoints
$w.resize (__.debounce (-> $.waypoints \refresh; respond-resize!; align-breadcrumb!), 800ms)

# show reply ui
append-reply-ui = (ev) ->
  # find post div
  $p = $ ev.target .parents \.post:first

  # append dom for reply ui
  unless $p.find('.reply .post-edit:visible').length
    render-and-append window,  $p.find(\.reply:first), \post-edit, (post:
      method:     \post
      forum_id:   $p.data(\forum-id) or window.active-forum-id
      parent_id:  $p.data \post-id
      is_comment: true), ->
        if ev.original-event then $p.find('textarea[name="body"]').focus! # user clicked
  else
    $p.find('.reply .cancel').click!

censor = (ev) ->
  $p = $ ev.target .parents \.post:first # find post div
  post-id = $p.data \post-id
  $.post "/resources/posts/#post-id/censor", (r) ->
    if r?success then $p.add-class \censored
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

window.r-searchopts = $R.state window.searchopts

do ->
  # keys that aren't allowed to trigger the search
  # use hashmap so its O(1)
  const blacklist = {
    9:1   # tab
    17:1  # ctrl
    18:1  # alt
    27:1  # escape
    32:1  # space
    37:1  # arrow (left)
    38:1  # arrow (up)
    39:1  # arrow (right)
    40:1  # arrow (down)
    224:1 # mac command key
  }

  $d.on \keyup, \#query, __.debounce (->
    q = $(@).val!

    # ignore special keys
    unless blacklist[it.which]
      if it.which is 13 # enter key
        submit-type = \hard
      else
        submit-type = \soft

      console.log "keyup:#{it.which} triggered a #{submit-type} search"

      r-searchopts({} <<< window.searchopts <<< {q, submit-type})
  ), 500ms

$d.on \change, '#search_filters [name=forum_id]', ->
  console.log it
  submit-type = \soft
  forum_id = $(@).val!

  r-searchopts({} <<< window.searchopts <<< {forum_id, submit-type})

  return false

$d.on \change, '#search_filters [name=within]', ->
  console.log it
  submit-type = \soft
  within = $(@).val!

  r-searchopts({} <<< window.searchopts <<< {within, submit-type})

  return false

$R((sopts) ->
  #should-search = sopts.submit-type is \hard or window.hints.current?mutator is \search
  #
  # WARNING!!!
  # XXX: this is a HACK
  # WARNING!!!
  #
  # I am doing this because in my testing I cannot rely on current mutator always being set properly when your on the search mutant!
  # I really DON'T want to but I am working around this weird shit so my filters will stop becoming unresponsive
  # we need to fix window.hints.current
  #
  parser = document.create-element \a
  parser.href = History.get-state!url
  uri = parser.pathname

  should-search = sopts.submit-type is \hard or uri is '/search'

  should-replace = sopts.submit-type is \soft

  # cleanup so it doesn't end up in url, only used to figure out push vs replace
  delete sopts.submit-type

  # strip out '', null, undefined, and 0 from querystring to keep it prety
  [k for k,v of sopts when not v].map -> delete sopts[it]

  if should-search
    console.log 'search request:', sopts
    qs = $.param sopts
    uri = "/search#{if qs then \? else ''}#{qs}"

    window.last-statechange-was-user = false # flag that this was programmer, not user
    if should-replace
      History.replace-state {}, '', uri
    else
      History.push-state {}, '', uri

).bind-to(r-searchopts)

$ui.on \thread-create, (e, thread) ->
  console.info 'thread-create', thread
  <- render-and-prepend window,  $('#left_container .threads'), \thread, thread:thread
  $ '#left_container .threads div.fadein li' .unwrap!

$ui.on \nav-top-posts, (e, threads) ->
  console.info \stub, threads

#}}}
# {{{ - generic form-handling ui
$d.on \click '.create .no-surf' ch.require-login(->
  $ '#main_content .forum' .html '' # clear canvas
  edit-post is-editing(window.location.pathname), forum_id:window.active-forum-id)
$d.on \click \.edit.no-surf ch.require-login(-> edit-post is-editing(window.location.pathname))
$d.on \click '.onclick-submit .cancel' (ev) ->
  f = $ ev.target .closest \.post-edit  # form
  f.hide 350ms \easeOutExpo
  meta = furl.parse window.location.pathname
  switch meta.type
  | \new-thread => History.back!
  | otherwise   => remove-editing-url meta
  false

submit = ch.require-login(
  (ev) -> submit-form(ev, (data) ->
    f = $ ev.target .closest \.post-edit # form
    p = f.closest \.editing # post being edited
    # render updated post
    p.find \.title .html data.0?title
    p.find \.body  .html data.0?body
    f.remove-class \fadein .hide 300s # & hide
    meta = furl.parse window.location.pathname
    window.last-statechange-was-user = false # flag that this was programmer, not user
    switch meta.type
    | \new-thread => History.replace-state {} '' data.uri
    | \edit       => remove-editing-url meta
    false))
$d.on \keydown \.onshiftenter-submit ~> if it.which is 13 and it.shift-key then submit it

submit-selectors =
  * "html.profile .onclick-submit input[type='submit']"
  * "html.forum .onclick-submit input[type='submit']"
  * "html.search .onclick-submit input[type='submit']"

$d.on \click, submit-selectors.join(', '), submit

$d.on \click \.onclick-append-reply-ui ch.require-login(append-reply-ui)
$d.on \click \.onclick-censor-post ch.require-login(censor)
#}}}
#{{{ - login delegated events
window.switch-and-focus = (remove, add, focus-on) ->
  $e = $ \.fancybox-wrap
  $e.remove-class("#remove shake slide").add-class(add)
  set-timeout (-> $e.add-class \slide; $ focus-on .focus! ), 10ms
$d.on \click \.onclick-close-fancybox ->
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
$d.on \click 'html header .menu a.title' ch.mutate

# search header
$d.on \click 'header .onclick-close' (e) ->
  $ \#query .val('').focus!
  History.back!
#{{{ - left_nav handle
$d.on \click \#handle ->
  $l = $ \#left_content
  $ \body .toggle-class \collapsed
  console.log($l.width! + left-offset)
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
#{{{ - chat
$d.on \click  'button.onclick-chat' ch.require-login( (ev) ->
  profile-name = $ 'div.profile:first' .data \user-name
  Chat.start [user.name, profile-name]
)
#}}}
#{{{ - admin
$d.on \click  'html.admin .onclick-submit input[type="submit"]' (ev) ->
  submit-form(ev, (data) ->
    f = $ this # form
    inputs =
     hover: f.find \.tooltip
     saved: f.find 'input, textarea'
    for k, v of inputs
      for e in v # indicated saved
        e = $ e
        e.add-class k
        if e.has-class \clear then e.val '' # clear value
    set-timeout (-> # reset ui
      for k, v of inputs
        for e in v
          $ e .remove-class k), 3000ms
    f.find \input:first .focus! # ... and focus!
  )
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

# components
window.component = {}

window.do-buy = ->
  window.component.buy ||= new Buy
  $.fancybox(window.component.buy.$)

window.do-test = ->
  new Buy {} $('body')
# vim:fdm=marker
