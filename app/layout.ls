# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites
# XXX helpers probably has crap we don't want in the client, refactor appropriately
window.helpers = require './helpers'
window.mutants = require './pb_mutants'

# shortcuts
$w = $ window
$d = $ document

is-ie     = false or \msTransform in document.documentElement.style
is-moz    = false or \MozBoxSizing in document.documentElement.style
is-opera  = !!(window.opera and window.opera.version)
threshold = 10px # snap

#.
#### main   ###############>======-- -   -
##
#{{{ Bootstrap Mutant Common
window.mutant  = require '../lib/mutant/mutant'
window.mutate  = (event) ->
  $e = $ this
  href = $e .attr \href
  return false unless href # guard
  return true if href?.match /#/
  params = {}
  params.no-surf = true if $e.has-class \no-surf
  History.push-state params, '', href
  false

$d.on \click 'a.mutant' window.mutate # hijack urls

History.Adapter.bind window, \statechange, (e) -> # history manipulaton
  url    = History.get-page-url!replace /\/$/, ''
  params = History.get-state!data
  unless params?.no-surf # DOM update handled outside mutant
    $.get url, _surf:1, (r) ->
      $d.attr \title, r.locals.title if r.locals?.title # set title
      on-unload = window.mutants[window.mutator].on-unload or (w, cb) -> cb null
      on-unload window, -> # cleanup & run next mutant
        window.mutant.run window.mutants[r.mutant], {locals:r.locals, window.user}
  return false
#}}}
#{{{ Scrolling behaviors
window.scroll-to-top = (cb) ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  do
    <- $e .animate { scroll-top:$ \body .offset!top }, 140ms
    <- $e .animate { scroll-top:$ \body .offset!top+threshold }, 110ms
    <- $e .animate { scroll-top:$ \body .offset!top }, 75ms
  if cb then cb!

window.awesome-scroll-to = (e, duration, cb) ->
  cb = -> noop=1 unless cb

  e     := $ e
  ms     = duration or 600ms
  offset = 100px

  return unless e.length # guard
  if is-ie or is-opera
    e[0].scroll-into-view!
    cb!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scrollY
    if Math.abs(dst-scroll - cur-scroll) > 30px
      #<- $ 'html,body' .animate { scroll-top:dst-scroll }, 140
      #<- $ 'html,body' .animate { scroll-top:dst-scroll+threshold }, 110
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms
    else
      cb!
  e

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scrollTop!
  $ \body .toggle-class 'scrolled' (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 1300ms # initially yield

# attach scroll-to's
$d.on \click '.scroll-to' ->
  awesome-scroll-to $(this).data \scroll-to
  false

# attach scroll-to-top's
$d.on \mousedown '.scroll-to-top' ->
  $ this .attr \title 'Scroll to Top!'
  window.scroll-to-top!
  false
#}}}
#{{{ 3rd-party auth
window.popup = (url) ->
  window.open url, "popup", "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"

$('.social a') .click ->
  url = $(this).attr \href
  popup url
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

# vim:fdm=marker
