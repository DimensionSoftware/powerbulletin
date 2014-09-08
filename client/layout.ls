define = window?define or require(\amdefine) module
require, exports, module <- define

require \jqueryHistory
require \jqueryUi
require \jqueryPostmessage

# XXX layout-specific client-side, and stuff we wanna reuse between sites
helpers = require \../shared/shared-helpers

{respond-resize, storage, switch-and-focus, mutate, show-tooltip, set-profile} = require \./client-helpers
window.Auth  = require \../component/Auth
window.switch-and-focus = switch-and-focus
window.storage = storage

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
#}}}
#{{{ Personalizing behaviors
window.onload-personalize = ->
  # TODO use a class on <body> and move this logic into stylus
  if window.user # logged in, so ...
    $ \#profile .remove-class \onclick-login
    $ \.onclick-profile  .each -> this.href = "/user/#{window.user.name}"
    $ \.onclick-login    .hide!
    $ \.onclick-logout   .show!
    $ \.onclick-profile  .show!
    # admin
    if user?rights?super or user?rights?admin then $ \.admin-only .show! else $ \.admin-only .hide!
  else
    $ \#profile .add-class \onclick-login
    $ \.onclick-login    .show!
    $ \.onclick-logout   .hide!
    $ \.onclick-profile  .hide!
    $ \.onclick-messages .hide!
    $ \.admin-only       .hide!
#}}}
#{{{ Resizing behaviors
window.onload-resizable = ->
  left-offset = 20px

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
        respond-resize!
        window.save-ui!)
    $r.css \padding-left ($l.width!+left-offset) # snap
  else
    try
      $l.resizable \destroy
#}}}
#{{{ Scrolling behaviors
window.scroll-to-top = (cb) ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  do
    <- $e .animate { scroll-top:0 }, 100ms
    <- $e .animate { scroll-top:(threshold/2)}, 80ms
    <- $e .animate { scroll-top:0 }, 45ms
  if typeof! cb is \Function then cb!
window.awesome-scroll-to = (e, duration, cb=->) ->
  e      = $ e
  ms     = duration or 800ms
  offset = 100px

  return unless e.length and e.is \:visible # guard
  if is-ie or is-opera
    e.0.scroll-into-view!
    cb!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scroll-y
    if Math.abs(dst-scroll - cur-scroll) > (threshold*2)
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms, \easeInOutExpo
      cb!
    else
      cb!
  e

# indicate to stylus that view scrolled
on-scroll-fn = ->
  st = $w.scroll-top!

  # handle header
  unless window.fixed-header
    if window.mutator isnt \forum or (helpers.is-forum-homepage window.location.pathname) # expand header when scrolled to top
      $ \body .toggle-class \scrolled (st > threshold)
    else if st > threshold
      $ \body .add-class \scrolled

  # handle footer
  if window.mutator is \forum or window.mutator is \profile
    $ \body .add-class \footer-show # always show footer on these (paginator)
  else
    $ \body .toggle-class \footer-show (st > threshold)

  if st is 0
    $ \header .remove-class \expanded
    $ \body .remove-class \minimized
    if window.fixed-header then $ \body .remove-class \scrolled
$ window .on \scroll _.debounce on-scroll-fn, 10ms


$ \header.header .on \dblclick (ev) ->
  if $ ev.target .has-class \header # pull down search when header is clicked
    h = $ this
    b = $ \body
    unless window.fixed-header then b.toggle-class \scrolled
    h.toggle-class \expanded
    set-timeout (-> $ \#query .focus!), 1ms # ...and focus search

# attach scroll-to's
$d.on \click '.onclick-scroll-to' ->
  awesome-scroll-to $(this).data \scroll-to
  false

# attach scroll-to-top's
$d.on \click \.onclick-scroll-top window.scroll-to-top; false
$d.on \mousedown \.onclick-scroll-top ->
  $ this .attr \title 'Scroll to Top!'
  window.scroll-to-top!
  false
#}}}
#{{{ Login & Authentication
window.shake-dialog = ($form, time) ->
  $fancybox = $form.parents(\.fancybox-wrap:first) .remove-class 'shake popin'
  set-timeout (-> $fancybox.add-class(\shake)), 100ms
  set-timeout (-> $fancybox.remove-class('shake popin')), 1500ms # cleanup (for other animations)

# logout
window.logout = ->
  storage.del \user
  window.location = \/auth/logout; false # for intelligent redirect
$d.on \click \.onclick-logout -> window.logout!; false
$d.on \click \.require-login, Auth.require-login(-> this.click)
$d.on \click \.onclick-login -> Auth.show-login-dialog!; false
$d.on \click \.onclick-newsletter -> Auth.show-newsletter-dialog!; false

# from /auth/$oauth/finish window
$.receive-message(((e) ->
  if e.data is \login
    Auth.login-with-token!),
    "https:#{auth-domain}"
)

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

window.time-updater = time-updater
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
$ \.tools .on \click ->
  t = $ '.tools menu' # close with force
    ..add-class \close
  b = $ '.tools .bubble, .tools .bubble2'
    ..add-class \close
  set-timeout (-> t.remove-class \close; b.remove-class \close), 2000ms # remove The Force


onload-resizable!

# run initial personalize ( based on parameters from user obj )
if (not (window.user = storage.get \user) or not window.user?name) # fetch (blocking)
  window.user <- $.getJSON \/auth/user
  storage.set \user, window.user # set latest
  after-user!
else # use locally stored user (non-blocking)
  after-user!
!function after-user #{{{
  if window.r-user then window.r-user window.user

  # hash actions
  if window.location.hash.match /^\#recover=/ then Auth.show-reset-password-dialog!
  if m = window.location.hash.match /^\#invalid=(.+)/ then Auth.show-info-dialog "Welcome back #{m.1}!"
  switch window.location.hash
  | \#invalid    => Auth.show-info-dialog 'Invalid invite code!'
  | \#validate   => Auth.after-login! # email activation
  | \#once       => Auth.login-with-token!
  | \#choose     => Auth.show-choose-dialog!
  | \#once-admin =>
    <- Auth.login-with-token!
    History.push-state null, null, \/admin

  onload-personalize!
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
