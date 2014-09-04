define = window?define or require(\amdefine) module
require, exports, module <- define

# XXX: hack hack hack!, this is to make sure that client-jade rather than component-jade gets loaded last
# this will not be necessary once we stop messing around with global/window state
require \../build/component-jade

require \jquery     # do this in the beginning, until all scripts are converted to lazy-style
__ = require \lodash # same... not sure where we use window.__ but whatever, legacy...

require! {
  \./globals
  $R: \./reactivejs
}

mutants = require \../shared/pb-mutants
mutant  = require \mutant
{find}  = require \prelude-ls

#XXX : more legacy, assumed to be globally present always, should be
# refactored so that each jquery plugin is only required where needed
# in the future... as opposed to using global-ness
require \jqueryHistory
require \jqueryTransit
require \jqueryUi
require \jqueryWaypoints
require \raf

require \layout

{storage, set-imgs, set-profile, align-ui, edit-post, fancybox-params, lazy-load-fancybox, mutate, post-success, remove-editing-url, respond-resize, set-wide, show-tooltip, show-info, submit-form, postdrawer} = require \./client-helpers
{render-and-append, render-and-prepend} = require \../shared/shared-helpers

#XXX: end legacy
window.MainMenu        = require \../component/MainMenu
window.Auth            = require \../component/Auth
window.PhotoCropper    = require \../component/PhotoCropper
window.PanelCollection = require \../component/PanelCollection
window.ChatList        = require \../component/ChatList
window.ChatPanel       = require \../component/ChatPanel
window.PostDrawer      = require \../component/PostDrawer

window.CensorReasonDialog = require \../component/CensorReasonDialog

window.furl     = require \../shared/forum-urls
window.tasks    = require \./tasks
window.ioc      = require \./io-client

# components
require! \../component/Buy
require! \../component/Paginator

# custom History.pushState function to get around statechange bug {{{
hostname = (url) ->
  m = url.match /^https?:\/\/(.*?)\/|^https?:\/\/(.*)$/
  if m
    [all, hs, hn] = m
    hs or hn
  else
    null

original-push-state = History.push-state

History.push-state = (a, b, url, c) ->
  h = hostname url
  if h and h isnt window.location.hostname
    link = $("a[href='#url'][target=_blank]")
    if link.length
      window.open url
    else
      window.location.href = url
  else
    original-push-state.call History, a, b, url, c
#}}}

# reactive vars
window.r-user = $R.state window.user

# XXX client-side entry
# shortcuts
$w = $ window
$d = $ document

left-offset = 50px

#{{{ UI Interactions
# ui save state
const sep = \-
const k-ui = "#{window.user?id}-ui"
window.get-prefs = ->
  s = storage.get k-ui
  if s then s.split sep else []
window.save-ui = -> # serialize ui state to local storage
  min = 200px
  w = $ \#left_content .width!
  h = $ \footer .height!
  [_, last-w, last-h] = window.get-prefs!
  w = if w > min then w else last-w or min # default
  h = if h > min then h else last-h or min # default
  vals =
    if $ \body .has-class(\collapsed) then 1 else 0
    w
    h
  storage.set k-ui, vals.join(sep),
    path:   \/
    secure: true
window.load-ui = -> # restore ui state from local storage
  s  = storage.get k-ui
  $l = $ \#left_content

  if s # restore
    [collapsed, w, h] = window.get-prefs!
    if collapsed is \1 and not $ \html .has-class \admin
      $ \body .add-class \collapsed # only collapse on non-admin mutants
    # animate build-in
    w = parse-int w
    $l.transition({width: w} 300ms \easeOutExpo -> set-wide!)
    $ '#main_content .resizable' .transition({padding-left: w+left-offset} 100ms \easeOutExpo)
  set-timeout (-> set-wide!; align-ui!; respond-resize!), 150ms

# waypoints
$w.resize (__.debounce (-> $.waypoints \refresh; respond-resize!; align-ui!), 800ms)

# show reply ui
append-reply-ui = (ev) ->
  focus = !($ ev.target .data \no-focus) # take focus?
  $p = $ ev.target .parents \.post:first # post div
  # append dom for reply ui
  unless $p.find('.reply .post-edit:visible').length
    render-and-append window,  $p.find(\.reply:first), \post-edit, (post:
      method:     \post
      forum_id:   $p.data(\forum-id) or window.active-forum-id
      parent_id:  $p.data \post-id
      is_comment: true), ->
        editor = $p.find 'textarea[name="body"]'
        if editor
          editor.autosize!
          if focus then editor.focus!
  else
    $p.find('.reply .cancel').click!

uncensor = (ev) ->
  $p = $ ev.target .parents \.post:first # find post div
  post-id = $p.data \post-id
  $m = $p.parents \.moderation:first
  $.post "/resources/posts/#post-id/uncensor", (r) ->
    if r?success then $p.remove-class \censored
    if mutator is \moderation then $m.slide-up 300ms

censor = (ev) ->
  $p = $ ev.target .parents \.post:first # find post div
  post-id = $p.data \post-id
  $.post "/resources/posts/#post-id/censor", (r) ->
    if r?success then $p.add-class \censored

show-censor-dialog = (ev) ->
  $p = $ ev.target .parents \.post:first
  post-id = $p.data \post-id
  c = new CensorReasonDialog locals: { post-id, $p }
  position = $p.position!
  new-position =
    top: position.top + $p.height! + 100px
    left: position.left + ($p.width! / 2)
  c.$.css new-position
  $ \body .append c.$

# left nav thread admin ui
window.r-show-thread-admin-ui = $R((user) ->
  if user and (user.sys_rights?super or user.rights?super)
    $ \ul.threads .add-class \admin
  else
    $ \ul.threads .remove-class \admin
).bind-to(window.r-user)
#}}}

#.
#### main   ###############>======-- -   -
##
set-imgs!
load-ui!
set-timeout (->
  $ \footer
    ..css \left $(\#left_content).width!+1
    ..add-class \active), 2500ms
$ \#query .focus!select!

# Delegated Events
#{{{ - search and ui delegated events
# window.ui is the object which will receive events and have events triggered on it
window.$ui = $ {}

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

      #console.log "keyup:#{it.which} triggered a #{submit-type} search"
      newopts = {} <<< window.searchopts <<< {q, submit-type}
      delete newopts.page # remove page from new term searches
      globals.r-searchopts newopts
  ), 500ms

$d.on \change, '#search_filters [name=forum_id]', ->
  submit-type = \soft
  forum_id = $(@).val!

  newopts = {} <<< window.searchopts <<< {forum_id, submit-type}
  delete newopts.page # remove page from new filtered results
  globals.r-searchopts newopts

  return false

$d.on \change, '#search_filters [name=within]', ->
  submit-type = \soft
  within = $(@).val!

  newopts = {} <<< window.searchopts <<< {within, submit-type}
  delete newopts.page # remove page from new filtered results
  globals.r-searchopts newopts

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
    #console.log 'search request:', sopts
    qs = $.param sopts
    uri = "/search#{if qs then \? else ''}#{qs}"

    window.last-statechange-was-user = false # flag that this was programmer, not user
    if should-replace
      History.replace-state {}, '', uri
    else
      History.push-state {}, '', uri

).bind-to(globals.r-searchopts)

$ui.on \thread-create, (e, thread) ->
  #console.info 'thread-create', thread
  <- render-and-prepend window,  $('#left_container .threads'), \thread, thread:thread
  $ '#left_container .threads div.fadein li' .unwrap!

$ui.on \nav-top-posts, (e, threads) ->
  #console.info \stub, threads

$ '.search > .icon' .on \click ->
  $ \#query .focus!select!
#}}}
# {{{ - generic form-handling ui
$d.on \click '.create .no-surf' Auth.require-login((ev) ->
  e = $ ev.target
  edit-post e.data(\edit), forum_id:window.active-forum-id)
$d.on \click \.edit.no-surf Auth.require-login((ev) ->
  edit-post $(ev.target).data \edit)
$d.on \click '.onclick-submit .cancel' (ev) ->
  f = $(ev.target).closest(\.post-edit)  # form
  f.slide-up 100ms \easeOutExpo
  meta = furl.parse window.location.pathname
  switch meta.type
  | \new-thread => History.back!
  | otherwise   => remove-editing-url meta
  false

submit = Auth.require-login(
  (ev) -> submit-form(ev, (data) ->
    f = $(ev.target).closest(\.post-edit) # form
    p = f.closest \.editing # post being edited
    t = $(f.find \.tooltip)
    unless data.success
      show-tooltip t, data?errors?join \<br>
    else
      # render updated post
      p.find \.title .html data.0?title
      p.find \.body  .html data.0?body
      f.remove-class \fadein .slide-up 100ms \easeOutExpo # & hide
      meta = furl.parse window.location.pathname
      window.last-statechange-was-user = false # flag that this was programmer, not user
      switch meta.type
      | \new-thread => History.replace-state {} '' data.uri
      | \edit       => remove-editing-url meta
    false))

# editing & posting
# - standard form
post-submit = Auth.require-login((ev) -> submit-form(ev, (data) -> post-success ev, data); false)

submit-selectors =
  * "html.profile .onclick-submit button[type='submit']"
  * "html.forum .onclick-submit button[type='submit']"
  * "html.search .onclick-submit button[type='submit']"
$d.on \click, submit-selectors.join(', '), post-submit
$d.on \keydown \.onenter-submit ~> if it.which is 13 and not it.shift-key then post-submit it; it.target?blur!

$d.on \click \.onclick-append-reply-ui Auth.require-login(append-reply-ui)
$d.on \click \.onclick-censor-post Auth.require-login(show-censor-dialog)
$d.on \click \.onclick-uncensor-post Auth.require-login(uncensor)
#}}}
#{{{ - header (main menu)
#$d.on \click 'html.homepage header .menu a.title' ->
#  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click \.opener -> $ \body .remove-class \minimized # bring out header (from content-only)
$d.on \click 'html header .menu a.title' mutate

# search header
$d.on \click 'header .onclick-close' (e) ->
  $ \#query .val('').focus!
  History.back!
#}}}
#{{{ - left_nav handle
$d.on \click \#handle ->
  $l = $ \#left_content
  [collapsed, w, h] = window.get-prefs!
  $ \body .toggle-class \collapsed
  $ '#main_content .resizable'
    .css(\padding-left, ($l.width! + w? + left-offset))
  save-ui!
  set-wide!

# thread sticky toggle
$d.on \click '.thread .sticky-toggle' (ev) ->
  $t = $(this).parents \.thread
  thread-id = $t.data \id
  $.post "/resources/posts/#thread-id/sticky", (r) ->
    if r?success
      if r.sticky
        $t.add-class \sticky
      else
        $t.remove-class \sticky

# thread locked toggle
$d.on \click '.thread .locked-toggle' (ev) ->
  $t = $(this).parents \.thread
  thread-id = $t.data \id
  $.post "/resources/posts/#thread-id/locked", (r) ->
    if r?success
      if r.locked
        $t.add-class \locked
      else
        $t.remove-class \locked
#}}}
# {{{ - Mocha testing harness
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
#{{{ - chat
$d.on \click  \.onclick-chat Auth.require-login( (ev) ->
  $p = $ \div.profile:first
  t  =
    id   : $p.data \user-id
    name : $p.data \user-name
  icon = $p.find \img .attr \src
  panels = window.component.panels

  err, c <- socket?emit \chat-between, [user.id, t.id]
  if err then return

  chat-panel = ChatPanel.add-from-conversation c, window.user
  panels.select-force "chat-#{c.id}"

)
#}}}
#{{{ - admin
function to-color d
  c = Number(d).to-string 16
  "\##{'000000'.substr(0, 6 - c.length) + c.to-upper-case!}"
function next-hex-value plus-or-minus, initial-v
  try v = parse-int((initial-v.replace /[^\da-zA-Z]*/, ''), 16)
  v = 0x000000 unless v
  switch plus-or-minus # inc/dec if in range
    | \plus  => (unless v >= 0xffffff then to-color (v + 0x000001) else v)
    | \minus => (unless v <= 0x000000 then to-color (v - 0x000001) else v)
function next-deg-value plus-or-minus, initial-v
  try v = parse-int(initial-v.replace /[^\d]*/, '')
  v = 0 unless v
  switch plus-or-minus # inc/dec if in range
    | \plus  => (unless v >= 360deg then (v + 1) + \deg else v + \deg)
    | \minus => (unless v <= 0deg   then (v - 1) + \deg else v + \deg)
$d.on \dblclick 'html.admin .dialog' (ev) ->
  return unless $ ev.target .has-class \dialog # guard
  l = $ ev.current-target .parents \.onclick-expand
    ..toggle-class \expanded, !(l.has-class \expanded)
  $ 'html.admin .theme .onclick-close' .hide!
$d.on \click 'html.admin .onclick-expand' (ev) -> # expand admin drop-downs
  return unless ($ ev.target .has-class \onclick-expand) # guard
  l = $ ev.current-target
    ..toggle-class \expanded, !(l.has-class \expanded)
  $ 'html.admin .theme .onclick-close' .hide!

$d.on \click 'html.admin .theme .preview' (ev) -> $ \#sprite_hue .focus!
$d.on \keyup 'html.admin .plus-minus.hex input' (ev) -> # inc/dec in hex
  i = $ ev.current-target # input
  switch ev.key-code
    | 38 => i.val(next-hex-value \plus, i.val!)  # plus
    | 39 => i.val(next-hex-value \plus, i.val!)
    | 40 => i.val(next-hex-value \minus, i.val!) # minus
    | 37 => i.val(next-hex-value \minus, i.val!)
$d.on \click 'html.admin .plus-minus.hex button' (ev) -> # inc/dec in hex
  e = $ ev.current-target     # button pressed
  i = e.prev-all \input:first # the input
    ..val next-hex-value (e.attr \class), i.val!
    ..keyup!
  <- set-timeout _, 100ms
  i.focus!select! # focus input
$d.on \keyup 'html.admin .plus-minus.degrees input' (ev) -> # inc/dec in degrees
  i = $ ev.current-target # input
  switch ev.key-code
    | 38 => i.val(next-deg-value \plus, i.val!)  # plus
    | 39 => i.val(next-deg-value \plus, i.val!)
    | 40 => i.val(next-deg-value \minus, i.val!) # minus
    | 37 => i.val(next-deg-value \minus, i.val!)
$d.on \click 'html.admin .plus-minus.degrees button' (ev) -> # inc/dec in degrees
  e = $ ev.current-target     # button pressed
  i = e.prev-all \input:first # the input
    ..val next-deg-value (e.attr \class), i.val!
  i.keyup!focus!select!       # focus input
$d.on \keyup 'html.admin .save' __.debounce (-> $d.find \form.onclick-submit .trigger \submit), 1000ms # trigger submit
$d.on \click 'html.admin .onclick-submit button[type="submit"], html.admin .save[type="checkbox"]' (ev) ->
  $d.find \form.onclick-submit .trigger \submit # trigger submit
  true
$d.on \submit \form.onclick-submit (ev) -> # use submit event to ensure form has finished updating
  # indicate we're saving
  t = $ \#warning
  b = $ ev.current-target # submit button
  b.attr \disabled, \disabled
  show-tooltip t, \Saving # hide for instant saves

  submit-form(ev, (data) ->
    f = $ this # form
    inputs = # class to apply & which input
      saved: f.find 'input, textarea'

    f.find \input:first .focus!select! unless f.has-class \no-focus
    if data?success
      if data.site then window.site = data.site # update site
      # indicated saved!
      b.remove-attr \disabled
      show-tooltip t, (data?msg or t.data(\msg) or \Saved!)

      # <ui updates>
      window.fixed-header = data.site.config?fixed-header
      # update config for domains (client)
      id = parse-int($ '#domain option:selected' .val!)
      if domain = find (-> it.id == id), site.domains
        for k in [
          #\facebookClientId
          \facebookClientSecret
          #\twitterConsumerKey
          \twitterConsumerSecret
          #\googleConsumerKey
          \googleConsumerSecret]
            domain.config[k] = $ "[name='#k']" .prop \checked
      for k, v of inputs
        for e in v
          e = $ e
          e.add-class k
          if e.has-class \clear then e.val '' # clear value
      set-timeout (-> # reset ui
        for k, v of inputs
          for e in v
            $ e .remove-class k), 3000ms
    else # indicated failure
      b.remove-attr \disabled
      show-tooltip t, (data?msg or data?messages?join \<br/>)
  )
  if $(ev.target).is \:button then ev.prevent-default! # no <form> submits
  false

$d.on \click 'html.admin .question' (ev) ->
  switch window.location.pathname
  | \/admin/menu =>
    show-info 0,
      [\.col1,              'Click &amp; Drag Menu Items to <b>Rearrange</b>', true],
      ['.col2 .has-dialog', 'Fill in the remaining information and Click <b>Save</b>']
  | \/admin/upgrade =>
    show-info 0, [\fieldset, 'Pro Upgrades are the Sharpest Tools Available for Your Community']
  | \/admin/invites =>
    show-info 0,
      [\#emails,                'Type in the <b>Email Address</b> of your VIPs'],
      [\#message,               'Include a Personalized Message <small>(optional)</small>'],
      ['button[type="submit"]', 'Click to <b>Send</b> an Invitation Link']
  | _ =>
    show-info 0, ['.col1, fieldset', '''
      Fill in the remaining information and Click <b>Save</b>
      <br/><small>Some inputs save automatically</small>
    ''']

$d.on \click \#add_custom_domain (ev) ->
  t = $ \#warning
  e = $ \#custom_domain
  n = e.val! # domain name to add
  if (n.length is 0) or (n.index-of \.) is -1 # guard
    show-tooltip t, 'Enter Your Domain!'
    $ \#custom_domain .focus!
    return

  unless \custom_domain in site.subscriptions then return # guard
  $.ajax {
    url: \/resources/domains
    type: \post
    data:
      name: n
    complete: (data) ->
      focus = -> e.focus!select!
      if data.responseJSON?success is true
        e.val '' # clear
        # add domain to dropdown/select input
        if domain = data.responseJSON?domain
          site.domains.push domain # append
          o = new Option n, domain.id
          $ o .html n
          $ \#domain
            ..append o
            ..val domain.id # select
            ..change!
        focus!
        show-tooltip t, "Congratulations, added #n!"
      else
        focus!
        show-tooltip t, data.responseJSON.errors?0
  }
$d.on \click 'html.admin .q' -> # close
  e = $ \.message
  if e.css(\max-height) isnt \0px # hide
    e.css {max-height: 0, padding:0}
    set-timeout (-> e.remove-attr \style), 2000ms # re-enable hovers
  else
    e.css {max-height:9999}
  false
$d.on \click 'html.admin .dialog textarea, html.admin .dialog button, html.admin .dialog input[type="text"], html.admin .dialog select' -> false # discard event
$d.on \click 'html.admin .preview' (ev) -> if ev?target then $ ev.target .prev \input .focus!; false
$d.on \change 'html.admin #domain' -> # set keys
  id = parse-int($ '#domain option:selected' .val!)
  if domain = find (-> it.id == id), site.domains
    $ \#facebook_auth .prop \checked, !!domain.config.facebookClientSecret
    $ \#twitter_auth .prop \checked, !!domain.config.twitterConsumerSecret
    $ \#google_auth .prop \checked, !!domain.config.googleConsumerSecret
set-private-state = ->
  c = $ \#private .is \:checked
  $ \#background_uploader .toggle-class \hidden, !c
  $ '#background_uploader + .note' .toggle-class \hidden !c
set-newsletter-state = ->
  c = $ \#newsletter .is \:checked
  $ '#newsletter_dialog' .toggle-class \hidden, !c
subscribe = (what) -> unless what in site.subscriptions
  do-buy what
  false
$d.on \click 'html.admin #analytics'         -> subscribe \analytics
$d.on \click 'html.admin #add_custom_domain' -> subscribe \custom_domain
$d.on \click 'html.admin #private' ->
  subscribe \private
  if \private in site.subscriptions
    set-private-state! # has bought?
    return true
  false # don't toggle ui
$d.on \click 'html.admin #newsletter' ->
  set-newsletter-state!
  set-timeout (-> $ \#newsletter_action .focus!), 50ms
  true

window.set-admin-ui = -> set-private-state!; set-newsletter-state!
set-timeout window.set-admin-ui, 10ms # init hidden/shown ui
#}}}
# {{{ - components
window.component = {}
$d.on \click \.onclick-messages (ev) ->
  p = window.component.panels
  unless p.find \chat-list
    p.add \chat-list, window.component.chat-list
  p.select-force \chat-list
  return false

$d.on \click \.onclick-buy (ev) -> do-buy($ ev.target .data \product)
window.do-buy = (product-id) ->
  throw new Error "window.do-buy must specify a product-id" unless product-id
  <- lazy-load-fancybox
  product <- $.get(\/resources/products/ + product-id)
  locals = {product, card-needed:!window.site?has_stripe}

  b = window.component?buy # existing?
  if b then b.detach!      # cleanup
  b = window.component.buy = new Buy {locals}
  $.fancybox b.$, fancybox-params

# kick-off main menu
window.component.main-menu = new MainMenu {-auto-render, locals:{}}, $ \#menu

# panels
postdrawer! # + PostDrawer singleton
window.component.panels = new PanelCollection {}
window.component.chat-list = new ChatList { locals: { p: window.component.panels, width: 350, css: { background: '#222' } } }
$ \body .append window.component.panels.$
#}}}
#{{{ - bootstrap mutant
# setup click hijackers for forum app only
# this should be moved into a forum-only module (not a shared module)
$d.on \click \a.mutant mutate # hijack urls
$d.on \click \button.mutant mutate # hijack urls

window.last-statechange-was-user = true # default state
last-req-id = 0

# FIXME there's a bug here where statechange binds to external links and causes a security exception!
History.Adapter.bind window, \statechange, (e) -> # history manipulaton
  statechange-was-user = window.last-statechange-was-user
  window.last-statechange-was-user = true # reset default state

  url    = History.get-page-url!replace /\/$/, ''
  params = History.get-state!data

  window.hints.last    <<< window.hints.current
  window.hints.current <<< { pathname: window.location.pathname, mutator: null }

  # if the previous and next mutations are between forum...
  #   generate recommendations
  if window.hints.last.mutator is \forum and not window.location.pathname.match /^\/(auth|admin|resources)/
    rc = window.tasks.recommendation window.location.pathname, window.hints.last.pathname

  unless params?no-surf # DOM update handled outside mutant
    spin true

    surf-params =
      _surf      : window.mutator
      _surf-data : params?surf-data
    if rc?keep?length
      surf-params._surf-tasks = rc.keep.sort!map( (-> tasks.cc it) ).join ','

    req-id = ++last-req-id
    jqxhr = $.get url, surf-params, (r) ->
      return if not r.mutant
      $d.attr \title, r.locals.title if r.locals?title # set title
      on-unload = mutants[window.mutator]?on-unload or (w, next-mutant, cb) -> cb null
      on-unload window, r.mutant, -> # cleanup & run next mutant
        # this branch will prevent queue pileups if someone hits the back/forward button very quickly
        # yeah we already requested the data but lets not needlessly update the dom when the user has
        # already specified they want to go to yet another url
        #
        # this fixes a bug where a slow loading page like the homepage for instance would update the dom
        # even after a new url had been specified with html history.. i.e. a forum page showed the homepage
        # because the homepage takes a lot longer to download and hence updated the dom after the forum
        # mutant had already done its thing
        if req-id is last-req-id # only if a new request has not been kicked off, can we run the mutant
          locals = {statechange-was-user} <<< r.locals

          mutant.run mutants[r.mutant], {locals, window.user}, ->
            onload-resizable!
            window.hints.current.mutator = window.mutator
            socket?emit \ping
            window.time-updater!
        #else
        #  console.log "skipping req ##{req-id} since new req ##{last-req-id} supercedes it!"
      spin false

    # capture error
    jqxhr.fail (xhr, status, error) ->
      show-tooltip $(\#warning), "Page Not Found", 8000ms
      #History.back! # XXX this causes bugs and occasionally fires multiple times
      window.spin false
#}}}
#
# register action
# get the user after a successful login
Auth.after-login = ->
  window.user <- $.getJSON \/auth/user
  if window.r-user then window.r-user window.user
  onload-personalize!
  if user and mutants?[window.mutator]?on-personalize
    set-profile user.photo
    mutants?[window.mutator]?on-personalize window, user, ->
      socket?disconnect!
      socket?socket?connect!

# run initial mutant
if window.initial-mutant
  <- mutant.run mutants[window.initial-mutant], {initial: true, window.user}

if u = storage.get \user # verify local user matches server
  server-user <- $.getJSON \/auth/user
  unless server-user?id is u.id
    show-tooltip ($ \#warning), 'Securing Your Connection'
    storage.del \user       # clear local storage
    window.location.reload! # & refresh


# disable "scroll overflow" of left bar into parent
$ document .on \wheel, '#left_container .scrollable' (ev) ->
    offset-top    = @scroll-top + parseInt(ev.original-event.delta-y, 10)
    offset-bottom = @scroll-height - @get-bounding-client-rect!height - offset-top
    if offset-top < 0 or offset-bottom < 0
      ev.prevent-default!
    else
      ev.stop-immediate-propagation!

# vim:fdm=marker
