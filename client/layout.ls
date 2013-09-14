define = window?define or require(\amdefine) module
require, exports, module <- define

require \jqueryHistory
require \jqueryNicescroll
require \jqueryUi

# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites
helpers = require \../shared/shared-helpers
mutants = require \../shared/pb-mutants

mutant  = require \mutant

require! ch: \./client-helpers
require! globals
window.Auth  = require \../component/Auth

window.cors =
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

window.hints =
  last:
    pathname: null
    mutator: null
  current:
    pathname: window.location.pathname
    mutator: window.mutator

# shortcuts
$w = $ window
$d = $ document

is-ie        = false or \msTransform in document.documentElement.style
is-moz       = false or \MozBoxSizing in document.documentElement.style
is-opera     = !!(window.opera and window.opera.version)
is-touchable = do ->
  try
    document.create-event \TouchEvent
    true
  catch
    false

const threshold = 15px # snap

#.
#### main   ###############>======-- -   -
##
#{{{ Bootstrap Mutant Common
$d.on \click \a.mutant ch.mutate # hijack urls
$d.on \click \button.mutant ch.mutate # hijack urls

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
  #   generte recommendations
  if window.hints.last.mutator is \forum and not window.location.pathname.match /^\/(auth|admin|resources)/
    rc = window.tasks.recommendation window.location.pathname, window.hints.last.pathname

  unless params?no-surf # DOM update handled outside mutant
    spin true

    surf-params =
      _surf      : mutator
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
      ch.show-tooltip $(\#warning), "Page Not Found", 8000ms
      History.back!
      window.spin false
#}}}
#{{{ Personalizing behaviors
window.onload-personalize = ->
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
      max-width: 450px
      resize: (e, ui) ->
        $l.toggle-class \wide ($l.width! > 300px)        # resize left nav
        $r.css \padding-left (ui.size.width+left-offset) # " resizable
        $ \footer .css \left (ui.size.width+1)
        $l.find \.scrollable .get-nice-scroll!resize!
        window.save-ui!)
    # TODO
    #  - would be nice to ease-expo-out on scroll
    #  - fix scrollable region to include another hundred px on bottom
    $l.find \.scrollable .nice-scroll {
      bouncescroll:    true
      cursorcolor:     \#bbb
      cursorwidth:     6
      hidecursordelay: 1000
      mousescrollstep: 6
      railoffset:      true
      railpadding:     {bottom:150px}}
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
    <- $e .animate { scroll-top:0 }, 250ms
    <- $e .animate { scroll-top:(threshold/2)}, 70ms
    <- $e .animate { scroll-top:0 }, 55ms
  cb!
window.awesome-scroll-to = (e, duration, cb=->) ->
  e      = $ e
  ms     = duration or 250ms
  offset = 10px

  return unless e.length # guard
  if is-ie or is-opera
    e.0.scroll-into-view!
    cb!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scroll-y
    if Math.abs(dst-scroll - cur-scroll) > (threshold*2)
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms
      <- $ 'html,body' .animate { scroll-top:dst-scroll+(threshold/2) }, 70ms
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, 50ms
      cb!
    else
      cb!
  e

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scroll-top!
  $ \body .toggle-class \scrolled (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 600ms # initially yield
$ \header.header .on \click (ev) ->
  if $ ev.target .has-class \header # pull down search when header is clicked
    b = $ \body
    if $w.scroll-top! > threshold
      b.toggle-class \scrolled
      set-timeout (-> $ \#query .focus!), 1ms # ...and focus search

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
  onload-personalize!
  if user and mutants?[window.mutator]?on-personalize
    ch.set-profile user.photo
    mutants?[window.mutator]?on-personalize window, user, ->
      socket?disconnect!
      socket?socket?connect!

# logout
window.logout = ->
  window.location = \/auth/logout; false # for intelligent redirect
$d.on \click \.onclick-logout -> window.logout!; false

$d.on \click \.require-login, Auth.require-login(-> this.click)
$d.on \click \.onclick-login -> Auth.show-login-dialog!; false
#$d.on \click '.toggle-password' toggle-password
#$d.on \submit '.login form' login
#$d.on \submit '.register form' register
#$d.on \submit '.forgot form' forgot-password
#$d.on \submit '.reset form' reset-password
#$d.on \submit '.choose form' choose

#}}}
#{{{ Keep human readable time up to date
time-updater = ->
  now = new Date
  $('[data-time]').each ->
    $el = $(this)

    d = new Date $el.data(\time)

    elapsed = (now - d) / 1000s
    hr = helpers.elapsed-to-human-readable elapsed

    # debug crap XXX: to figure out what is going on with time
    # TODO: remove me
    lh = $el.data(\last-human)
    #if lh isnt hr
      #console.log "human-readable time changed", {elapsed, lh, hr}
    $el.data(\last-human, hr)

    if $el.has-class 'time-title'
      $el.attr \title, hr.replace(/<.*?\/?>/g, '')
    else
      $el.html hr

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
window.user <- $.getJSON \/auth/user
globals.r-user window.user

# hash actions
if window.location.hash.match /^\#recover=/ then Auth.show-reset-password-dialog!
if m = window.location.hash.match /^\#invalid=(.+)/ then Auth.show-info-dialog "Welcome back #{m.1}!"
switch window.location.hash
| \#invalid  => Auth.show-info-dialog 'Invalid invite code!'
| \#validate => Auth.after-login! # email activation
| \#once     => Auth.login-with-token!

onload-personalize!
if window.initial-mutant # XXX sales-app doesn't have a mutant
  <- mutant.run mutants[window.initial-mutant], {initial: true, window.user}
$ '.tools .profile' .show! # show default avatar
# vim:fdm=marker
