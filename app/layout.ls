# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites
window.helpers = require \./shared_helpers
window.mutants = require \./pb_mutants

# shortcuts
$w = $ window
$d = $ document

spin = (loading = true) ->
  $b ||= $('body')
  if loading
    $b.add-class \waiting
  else
    $b.remove-class \waiting


is-ie     = false or \msTransform in document.documentElement.style
is-moz    = false or \MozBoxSizing in document.documentElement.style
is-opera  = !!(window.opera and window.opera.version)
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
  History.push-state params, '', href
  false

$d.on \click \a.mutant window.mutate # hijack urls

History.Adapter.bind window, \statechange, (e) -> # history manipulaton
  url    = History.get-page-url!replace /\/$/, ''
  params = History.get-state!data

  unless params?no-surf # DOM update handled outside mutant
    spin(true)
    $.get url, {_surf:mutator, _surf-data:params.surf-data}, (r) ->
      $d.attr \title, r.locals.title if r.locals?title # set title
      on-unload = window.mutants[window.mutator].on-unload or (w, cb) -> cb null
      on-unload window, -> # cleanup & run next mutant
        window.mutant.run window.mutants[r.mutant], {locals:r.locals, window.user}, ->
          on-load-resizable!
          spin(false)

  return false
#}}}
#{{{ Resizing behaviors
window.on-load-resizable = ->
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
      window.save-ui!)
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
    else
      cb!
  e

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scrollTop!
  $ \body .toggle-class \scrolled (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 1300ms # initially yield

# attach scroll-to's
$d.on \click '.scroll-to' ->
  awesome-scroll-to $(this).data \scroll-to
  false

# attach scroll-to-top's
$d.on \mousedown \.scroll-to-top ->
  $ this .attr \title 'Scroll to Top!'
  window.scroll-to-top!
  false
#}}}
#{{{ Login & Authentication
window.show-login-dialog = ->
  $.fancybox.open '#auth'
  setTimeout (-> $ '#auth input[name=username]' .focus! ), 100ms

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
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100ms
  false

# get the user after a successful login
window.after-login = ->
  window.user <- $.getJSON '/auth/user'
  if user then window.mutants?[window.mutator]?on-personalize window, user, ->
    socket?disconnect!
    socket?socket?connect!

# logout
window.logout = ->
  r <- $.get '/auth/logout'
  window.location.reload!

# register
window.register = ->
  $form = $(this)
  $form.find("input").remove-class \validation-error
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $form.find("input:text,input:password").remove-class(\validation-error).val ''
      switch-and-focus \on-register \on-validate ''
    else
      r.errors?for-each (e) ->
        $form.find("input[name=#{e.param}]").add-class \validation-error .focus!
      $fancybox = $form.parents('.fancybox-wrap:first') .remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake)), 100ms
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
$d.on \click '.require-login' require-login(-> this.click)

# 3rd-party auth
$ '.social a' .click ->
  url = $ this .attr(\href)
  window.open url, \popup, "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"
  false
#}}}
#{{{ Form submission
window.submit-form = (event, fn) ->
  $f = $ event.target .closest(\form) # get event's form

  # update textarea body from sceditor
  $e = $ \textarea.body
  $e.html $e.data!sceditor?val! if $e.length and $e.data!sceditor

  $.ajax {
    url:      $f.attr(\action)
    type:     $f.attr(\method)
    data:     $f.serialize!
    data-type: \json
    success:  (data) ->
      if fn then fn.call $f, data}
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
    $el.text hr

set-interval time-updater, 30000ms
#}}}

# personalization ( based on parameters from user obj )
window.user <- $.getJSON '/auth/user'

# run initial mutant
window.mutant.run window.mutants[window.initial-mutant], {initial: true, window.user}
on-load-resizable!

# vim:fdm=marker
