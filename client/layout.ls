define = window?define or require(\amdefine) module
require, exports, module <- define

require \jqueryHistory
require \jqueryUi

# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites
helpers = require \../shared/shared-helpers
mutants = require \../shared/pb-mutants
mutant  = require \mutant

{storage, switch-and-focus, mutate, show-tooltip, set-profile} = require \./client-helpers
require! globals
window.Auth  = require \../component/Auth
window.switch-and-focus = switch-and-focus

window.cors = #{{{
  ajax-params:
    xhr-fields:
      with-credentials: true
    success: (->)
    error: (->)
  get: (url, data, cb) ->
    params = {}
    params <<< @ajax-params
    params <<< { type: \GET, url, data }
    params.success = cb if cb
    $.ajax params
  post: (url, data, cb) ->
    params = {}
    params <<< @ajax-params
    params <<< { type: \POST, url, data }
    params.success = cb if cb
    $.ajax params
#}}}
window.hints = #{{{
  last:
    pathname: null
    mutator: null
  current:
    pathname: window.location.pathname
    mutator: window.mutator
#}}}
#{{{ Portability
is-ie        = false or \msTransform in document.documentElement.style
is-moz       = false or \MozBoxSizing in document.documentElement.style
is-opera     = !!(window.opera and window.opera.version)
is-touchable = do ->
  try
    document.create-event \TouchEvent
    true
  catch
    false
#}}}

# shortcuts
$w = $ window
$d = $ document

const threshold = 15px # snap

#.
#### main   ###############>======-- -   -
##
#{{{ Bootstrap Mutant Common

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
#{{{ Personalizing behaviors
window.onload-personalize = ->
  # TODO use a class on <body> and move this logic into stylus
  if window.user # logged in, so ...
    $ \.onclick-profile .each -> this.href = "/user/#{window.user.name}"
    $ \.onclick-login   .hide!
    $ \.onclick-logout  .show!
    $ \.onclick-profile .show!
    # admin
    if user?rights?super or user?rights?admin then $ \.admin-only .show! else $ \.admin-only .hide!
  else
    $ \.onclick-login   .show!
    $ \.onclick-logout  .hide!
    $ \.onclick-profile .hide!
    $ \.admin-only      .hide!
#}}}
#{{{ Resizing behaviors
window.onload-resizable = ->
  left-offset = 50px

  $l = $ \#left_content
  $r = $ '#main_content .resizable'

  if $r.length
    $l.resizable(
      min-width: 200px
      max-width: 550px
      resize: (e, ui) ->
        $l.toggle-class \wide ($l.width! > 300px)        # resize left nav
        $r.css \padding-left (ui.size.width+left-offset) # " resizable
        $ \footer .css \left (ui.size.width+1)
        window.save-ui!)
    $r.css \padding-left ($l.width!+left-offset) # snap
  else
    try
      $l.resizable \destroy
#}}}
#{{{ Scrolling behaviors
window.scroll-to-top = (cb=->) ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  do
    <- $e .animate { scroll-top:0 }, 100ms
    <- $e .animate { scroll-top:(threshold/2)}, 80ms
    <- $e .animate { scroll-top:0 }, 45ms
  cb!
window.awesome-scroll-to = (e, duration, cb=->) ->
  e      = $ e
  ms     = duration or 1000ms
  offset = 100px

  return unless e.length # guard
  if is-ie or is-opera
    e.0.scroll-into-view!
    cb!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scroll-y
    if Math.abs(dst-scroll - cur-scroll) > (threshold*2)
      bounce = threshold / 3
      #<- $ 'html,body' .animate { scroll-top:dst-scroll+bounce }, ms, \easeOutExpo
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms, \easeOutExpo
      cb!
    else
      cb!
  e

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scroll-top!
  $ \body .toggle-class \scrolled (st > threshold)
  if st is 0 then $ \header .remove-class \expanded
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 600ms # initially yield
$ \header.header .on \click (ev) ->
  if $ ev.target .has-class \header # pull down search when header is clicked
    h = $ this
    b = $ \body
    if $w.scroll-top! > threshold
      b.toggle-class \scrolled
      h.add-class \expanded
      set-timeout (-> $ \#query .focus!), 1ms # ...and focus search
    else
      h.remove-class \expanded

# attach scroll-to's
$d.on \click '.onclick-scroll-to' ->
  awesome-scroll-to $(this).data \scroll-to
  false

# attach scroll-to-top's
$d.on \mousedown \.onclick-scroll-top ->
  $ this .attr \title 'Scroll to Top!'
  window.scroll-to-top!
  false
#}}}
#{{{ Login & Authentication
window.shake-dialog = ($form, time) ->
  $fancybox = $form.parents(\.fancybox-wrap:first) .remove-class \shake
  set-timeout (-> $fancybox.add-class(\shake)), 100ms

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

# logout
window.logout = ->
  window.location = \/auth/logout; false # for intelligent redirect
$d.on \click \.onclick-logout -> window.logout!; false
$d.on \click \.require-login, Auth.require-login(-> this.click)
$d.on \click \.onclick-login -> Auth.show-login-dialog!; false

#}}}
#{{{ Keep human readable time up to date
time-updater = ->
  now = new Date
  $('[data-time]').each ->
    $el = $(this)

    d = new Date $el.data(\time)

    elapsed = (now - d) / 1000s
    hr = helpers.elapsed-to-human-readable elapsed
    fr = helpers.friendly-date-string d

    $el.data(\last-human, hr)

    $el.attr \title, fr

    # chat doesn't want its html replaced
    if not $el.has-class 'time-title'
      $el.html hr

window.time-updater = time-updater # XXX remove me
time-updater!
set-interval time-updater, 30000ms
#}}}
#{{{ Loading cursor spinner
var show-timeout-id
var hide-timeout-id
window.spin = (loading = true) ->
  time-until-show = 500ms
  time-until-hide = 6500ms

  clear-timeout show-timeout-id
  clear-timeout hide-timeout-id

  $b ||= $('body')
  show = ->
    $b.add-class \waiting
    hide-timeout-id := set-timeout hide, time-until-hide
  hide = ->
    $b.remove-class \waiting

  if loading
    show-timeout-id := set-timeout show, time-until-show
  else
    hide!
#}}}

onload-resizable!

# run initial mutant & personalize ( based on parameters from user obj )
if not (window.user = storage.get \user) # fetch (blocking)
  fetch-and-set-user after-user
else # use locally stored user (non-blocking)
  after-user!
  if parse-int(Math.random!*3) is 1
    fetch-and-set-user! # lazy update (minimize stale client)
#{{{ User-related
!function fetch-and-set-user cb=(->)
  console.log \fetch
  window.user <- $.getJSON \/auth/user
  storage.set \user, window.user # set latest
  cb!
!function after-user
  if window.r-user then window.r-user window.user

  # hash actions
  if window.location.hash.match /^\#recover=/ then Auth.show-reset-password-dialog!
  if m = window.location.hash.match /^\#invalid=(.+)/ then Auth.show-info-dialog "Welcome back #{m.1}!"
  switch window.location.hash
  | \#invalid    => Auth.show-info-dialog 'Invalid invite code!'
  | \#validate   => Auth.after-login! # email activation
  | \#once       => Auth.login-with-token!
  | \#once-admin =>
    <- Auth.login-with-token!
    History.push-state null, null, \/admin

  onload-personalize!
  if window.initial-mutant # XXX sales-app doesn't have a mutant
    <- mutant.run mutants[window.initial-mutant], {initial: true, window.user}
  $ '.tools .profile' .show! # show default avatar
  # advertise
  console?log '''
  ░█▀█░█▀█░█░█░█▀▀░█▀▄░█▀▄░█░█░█░░░█░░░█▀▀░▀█▀░▀█▀░█▀█
  ░█▀▀░█░█░█▄█░█▀▀░█▀▄░█▀▄░█░█░█░░░█░░░█▀▀░░█░░░█░░█░█
  ░▀░░░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀░░▀▀▀░▀▀▀░▀▀▀░▀▀▀░░▀░░▀▀▀░▀░▀
  Hey, you-- join us!  https://powerbulletin.com
  '''
#}}}
# vim: fdm=marker
