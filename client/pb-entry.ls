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
require \jqueryMasonry
require \jqueryTransit
require \jqueryUi
require \jqueryWaypoints
require \raf

require \layout

{storage, set-imgs, align-ui, ck-submit-form, edit-post, fancybox-params, lazy-load-fancybox, mutate, post-success, remove-editing-url, respond-resize, set-wide, show-tooltip, submit-form} = require \./client-helpers
{render-and-append, render-and-prepend} = require \../shared/shared-helpers

#XXX: end legacy
window.MainMenu        = require \../component/MainMenu
window.Auth            = require \../component/Auth
window.PhotoCropper    = require \../component/PhotoCropper
window.PanelCollection = require \../component/PanelCollection
window.ChatPanel       = require \../component/ChatPanel

window.furl     = require \../shared/forum-urls
window.tasks    = require \./tasks
window.ioc      = require \./io-client
window <<< {ck-submit-form}

# components
require! \../component/Buy
require! \../component/Paginator

# XXX client-side entry
# shortcuts
$w = $ window
$d = $ document

left-offset = 50px

#{{{ UI Interactions
# ui save state
const sep = \-
const k-ui = "#{window.user?id}-ui"
window.save-ui = -> # serialize ui state to local storage
  min-width = 200px
  w = $ \#left_content .width!
  s = storage.get k-ui
  if s then [_, last] = s.split sep
  w = if w > min-width then w else last or min-width # default
  vals =
    if $ \body .has-class(\collapsed) then 1 else 0
    w
  storage.set k-ui, vals.join(sep),
    path:   \/
    secure: true
window.load-ui = -> # restore ui state from local storage
  s  = storage.get k-ui
  $l = $ \#left_content

  if s # restore
    [collapsed, w] = s.split sep
    if collapsed is \1 and not $ \html .has-class \admin
      $ \body .add-class \collapsed # only collapse on non-admin mutants
    # animate build-in
    w = parse-int w
    $l.transition({width: w} 600ms \easeOutExpo -> set-wide!)
    $ '#main_content .resizable' .transition({padding-left: w+left-offset} 300ms \easeOutExpo)
  set-timeout (-> set-wide!; align-ui!; respond-resize!), 500ms

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
        editor.autosize!
        if focus then editor.focus!
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

#}}}
# {{{ - generic form-handling ui
$d.on \click '.create .no-surf' Auth.require-login((ev) ->
  $ '#main_content .forum' .html '' # clear canvas
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
# - ckeditor
ck-submit = Auth.require-login((ev) ->
  ck-submit-form({element:{$:{id:\editor}}}, (data) -> post-success ev, data); false)
# - standard form
post-submit = Auth.require-login((ev) -> submit-form(ev, (data) -> post-success ev, data); false)

submit-selectors =
  * "html.profile .onclick-submit button[type='submit']"
  * "html.forum .onclick-submit button[type='submit']"
  * "html.search .onclick-submit button[type='submit']"
$d.on \click, submit-selectors.join(', '), post-submit
$d.on \keydown \.onenter-submit ~> if it.which is 13 and not it.shift-key then post-submit it; it.target?blur!

$d.on \click \.onclick-append-reply-ui Auth.require-login(append-reply-ui)
$d.on \click \.onclick-censor-post Auth.require-login(censor)
#}}}
#{{{ - header (main menu)
#$d.on \click 'html.homepage header .menu a.title' ->
#  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html header .menu a.title' mutate

# search header
$d.on \click 'header .onclick-close' (e) ->
  $ \#query .val('').focus!
  History.back!
#{{{ - left_nav handle
$d.on \click \#handle ->
  s  = storage.get k-ui
  $l = $ \#left_content
  if s then [collapsed, w] = s.split sep
  $ \body .toggle-class \collapsed
  $ '#main_content .resizable'
    .css(\padding-left, ($l.width! + w? + left-offset))
  save-ui!
  set-wide!
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
$d.on \click  \.onclick-chat Auth.require-login( (ev) ->
  $p = $ \div.profile:first
  t  =
    id     : $p.data \user-id
    name   : $p.data \user-name
  icon = $p.find \img .attr \src
  panels = window.component.panels

  # XXX - this is wrong.  It needs to ask the server for a chat id.
  id = "chat-#{$p.data \user-id}"

  # XXX - it needs to ask the ChatPanel if a panel exists for the given chat id.
  chat-panel-exists = $ "\##{id}" .length

  if chat-panel-exists
    panels.select-force id
  else
    chat-panel = new ChatPanel locals: { id, icon, to: t, width: 300px, css: { background: '#544', opacity: 0.85 }, p: panels }
    panels.add id, chat-panel
    panels.select-force id
)
#}}}
#{{{ - admin
$d.on \click 'html.admin .onclick-submit button[type="submit"], html.admin [type="checkbox"]' (ev) ->
  submit-form(ev, (data) ->
    f = $ this # form
    t = $ \#warning
    inputs = # class to apply & which input
      saved: f.find 'input, textarea'

    f.find \input:first .focus!select! unless f.has-class \no-focus
    if data?success
      # indicated saved
      show-tooltip t, (t.data(\msg) or \Saved!)
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
      show-tooltip t, data?msg
  )
  true

$d.on \change 'html.admin .domain' -> # set keys
  id = parse-int($ '.domain option:selected' .val!)
  #console.log \parsed_id, id
  domain = find (->
    #console.log \actual_id, it.id
    it.id == id
  ), site.domains
  #domain = find (.id is id), site.domains
  for k in [
    \facebookClientId
    \facebookClientSecret
    \twitterConsumerKey
    \twitterConsumerSecret
    \googleConsumerKey
    \googleConsumerSecret]
      $ "[name='#k']" .val domain.config[k]
subscribe = (what) -> unless what in site.subscriptions
  do-buy what
  false
$d.on \click 'html.admin #private'   -> subscribe \private
$d.on \click 'html.admin #analytics' -> subscribe \analytics
#}}}
# {{{ - components
window.component = {}

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
window.component.panels = new PanelCollection {}
$ \body .append window.component.panels.$
#}}}
#{{{ - bootstrap mutant
#XXX DIRTY DIRTY DIRTY HACK ALERT! (need more decoupling love here)
if window.location.host not in [\powerbulletin.com, \pb.com]

  # setup click hijackers for forum app only
  # this should be moved into a forum-only module (not a shared module)
  $d.on \click \a.mutant mutate # hijack urls
  $d.on \click \button.mutant mutate # hijack urls

window.last-statechange-was-user = true # default state
last-req-id = 0

#XXX DIRTY DIRTY DIRTY HACK ALERT! (need more decoupling love here)
if window.location.host not in [\powerbulletin.com, \pb.com]
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
              spin false
          #else
          #  console.log "skipping req ##{req-id} since new req ##{last-req-id} supercedes it!"

      # capture error
      jqxhr.fail (xhr, status, error) ->
        show-tooltip $(\#warning), "Page Not Found", 8000ms
        History.back!
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
# vim:fdm=marker
