# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites
window.helpers = require \./shared-helpers
window.mutants = require \./pb-mutants

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

threshold = 10px # snap

#.
#### main   ###############>======-- -   -
##
#{{{ Bootstrap Mutant Common
window.mutant  = require \../lib/mutant/mutant
window.mutate  = (event) ->
  $e = $ this
  return if $e.has-class \require-login and !user # guard
  href = $e .attr \href
  return false unless href # guard
  return true if href?match /#/
  params = {}

  # surfing
  params.no-surf   = true if $e.has-class \no-surf             # no need to fetch surf data
  params.surf-data = $e.data \surf or window.surf-data or void # favor element data on click
  window.last-statechange-was-user = false # flag that this was programmer, not user
  History.push-state params, '', href
  false

$d.on \click \a.mutant window.mutate # hijack urls

window.last-statechange-was-user = true # default state
last-req-id = 0
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
    $.get url, surf-params, (r) ->
      return if not r.mutant
      $d.attr \title, r.locals.title if r.locals?title # set title
      on-unload = window.mutants[window.mutator].on-unload or (w, next-mutant, cb) -> cb null
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

          window.mutant.run window.mutants[r.mutant], {locals, window.user}, ->
            onload-resizable!
            window.hints.current.mutator = window.mutator
            spin false
        else
          console.log "skipping req ##{req-id} since new req ##{last-req-id} supercedes it!"
#}}}
#{{{ Personalizing behaviors
window.onload-personalize = ->
  if window.user # logged in, so ...
    $ \.onclick-profile .each -> this.href = "/user/#{window.user.name}"
    $ \.onclick-login   .hide!
    $ \.onclick-logout  .show!
    $ \.onclick-profile .show!
    unless user?rights?super then $ \.admin-only .hide! else $ \.admin-only .show!
  else
    $ \.onclick-login   .show!
    $ \.onclick-logout  .hide!
    $ \.onclick-profile .hide!
    $ \.admin-only      .hide!
#}}}
#{{{ Resizing behaviors
window.onload-resizable = ->
  left-offset = 50px

  # handle main content
  $r = $ '#main_content .resizable'

  # handle left
  $l = $ \#left_content
  $l.resizable(
    min-width: 200px
    max-width: 450px
    resize: (e, ui) ->
      $l.toggle-class \wide ($l.width! > 300px)        # resize left nav
      $r.css \padding-left (ui.size.width+left-offset) # " resizable
      $l.find \.scrollable .get-nice-scroll!resize!
      window.save-ui!)
  # TODO
  #  - would be nice to ease-expo-out on scroll
  #  - fix scrollable region to include another few hundred px on bottom
  $l.find(\.scrollable).nice-scroll {
    bouncescroll:    true
    cursorcolor:     \#aaa
    cursorwidth:     2
    hidecursordelay: 800
    mousescrollstep: 5
    railoffset:      true
    railpadding:     {bottom:50px}}
  if $r.length
    $r.css \padding-left ($l.width!+left-offset) # snap
#}}}
#{{{ Scrolling behaviors
window.scroll-to-top = (cb=->) ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  do
    <- $e .animate { scroll-top:0 }, 200ms
    <- $e .animate { scroll-top:threshold }, 110ms
    <- $e .animate { scroll-top:0 }, 75ms
  cb!
window.awesome-scroll-to = (e, duration, cb=->) ->
  e      = $ e
  ms     = duration or 500ms
  offset = 10px

  return unless e.length # guard
  if is-ie or is-opera
    e.0.scroll-into-view!
    cb!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scrollY
    if Math.abs(dst-scroll - cur-scroll) > 30px
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms
      <- $ 'html,body' .animate { scroll-top:dst-scroll+threshold }, 110ms
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, 75ms
#      new-cur-scroll = Math.round(e.position!top) - offset
#      if dst-scroll isnt new-cur-scroll # try again
#        set-timeout (-> $ 'html,body' .animate { scroll-top:dst-scroll }, 50ms), 100ms
      cb!
    else
      cb!
  e

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scrollTop!
  $ \body .toggle-class \scrolled (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 600ms # initially yield

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

window.show-login-dialog = ->
  $.fancybox.open \#auth,
    close-effect: \elastic
    close-speed:  200ms
    close-easing: \easeOutExpo
    open-effect: \fade
    open-speed: 300ms
  setTimeout (-> $ '#auth input[name=username]' .focus! ), 100ms
$d.on \click \.onclick-login -> window.show-login-dialog!; false

# register action
# login action
window.login = ->
  $form = $(this)
  u = $form.find('input[name=username]')
  p = $form.find('input[name=password]')
  params =
    username: u.val!
    password: p.val!
  $.post $form.attr(\action), params, (r) ->
    if r.success
      $.fancybox.close!
      after-login!
    else
      $fancybox = $form.parents('.fancybox-wrap:first')
      $fancybox.add-class \on-error
      $fancybox.remove-class \shake
      show-tooltip $form.find(\.tooltip), 'Try again!' # display error
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100ms
  false

# get the user after a successful login
window.after-login = ->
  window.user <- $.getJSON \/auth/user
  onload-personalize!
  if user and window.mutants?[window.mutator]?on-personalize
    window.mutants?[window.mutator]?on-personalize window, user, ->
      socket?disconnect!
      socket?socket?connect!

# logout
window.logout = ->
  window.location = \/auth/logout; false # for intelligent redirect
$d.on \click \.onclick-logout -> window.logout!; false

# register
window.register = ->
  $form = $(this)
  $form.find(\input).remove-class \validation-error
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $form.find("input:text,input:password").remove-class(\validation-error).val ''
      switch-and-focus \on-register \on-validate ''
    else
      # NOTE:  Only the last tooltip is shown and only the last input is focused.
      r.errors?for-each (e) ->
        $e = $form.find("input[name=#{e.param}]")
        $e.add-class \validation-error .focus!    # focus control
        show-tooltip $form.find(\.tooltip), e.msg # display error
      shake-dialog $form, 100ms
  return false

$d.on \submit '.login form' login
$d.on \submit '.register form' register

# require that window.user exists before calling fn
window.require-login = (fn) ->
  ->
    if window.user
      fn.apply this, arguments
    else
      show-login-dialog!
      false
$d.on \click \.require-login require-login(-> this.click)

# forgot password
window.forgot-password = ->
  $form = $ this
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      show-tooltip $form.find(\.tooltip), "Recovery link emailed!"
    else
      show-tooltip $form.find(\.tooltip), "Email not found."
      shake-dialog $form, 100ms
  return false

$d.on \submit '.forgot form' forgot-password

window.show-reset-password-dialog = ->
  $form = $ '#auth .reset form'
  show-login-dialog!
  set-timeout (-> switch-and-focus '', \on-reset, '#auth .reset input:first'), 500ms
  hash = location.hash.split('=')[1]
  $form.find('input[type=hidden]').val(hash)
  $.post '/auth/forgot-user', { forgot: hash }, (r) ->
    if r.success
      $form .find 'h2:first' .html 'Choose a New Password'
      $form .find('input').prop('disabled', false)
    else
      $form .find 'h2:first' .html "Couldn't find you. :("

window.reset-password = ->
  $form = $ this
  password = $form.find('input[name=password]').val!
  if password.match /^\s*$/
    show-tooltip $form.find(\.tooltip), "Password may not be blank."
    return false
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $form.find('input').prop(\disabled, true)
      show-tooltip $form.find(\.tooltip), "Password changed!"
      location.hash = ''
      $form.find('input[name=password]').val('')
      set-timeout ( ->
        switch-and-focus \on-reset, \on-login, '#auth .login input:first'
        show-tooltip $('#auth .login form .tooltip'), "Now log in!"
      ), 1500ms
    else
      show-tooltip $form.find(\.tooltip), "Choose a better password."
  return false

$d.on \submit '.reset form' reset-password

# 3rd-party auth
$ '.social a' .click ->
  url = $ this .attr(\href)
  window.open url, \popup, "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"
  false
#}}}
#{{{ Keep human readable time up to date
time-updater = ->
  now = new Date
  $('[data-time]').each ->
    $el = $(this)

    d = new Date $el.data(\time)

    elapsed = (now - d) / 1000s
    hr = window.helpers.elapsed-to-human-readable elapsed

    # debug crap XXX: to figure out what is going on with time
    # TODO: remove me
    lh = $el.data(\last-human)
    #if lh isnt hr
      #console.log "human-readable time changed", {elapsed, lh, hr}
    $el.data(\last-human, hr)

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
onload-personalize!

if window.location.hash.match /^\#recover=/
  show-reset-password-dialog!

window.mutant.run window.mutants[window.initial-mutant], {initial: true, window.user}, ->
  mutant = window.mutants?[window.initial-mutant]
  if mutant.on-personalize
    mutant.on-personalize window, window.user, (->)


# vim:fdm=marker
