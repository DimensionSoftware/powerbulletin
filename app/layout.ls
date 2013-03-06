# XXX layout-specific client-side, and stuff we wanna reuse between mutant-powered sites

# XXX: helpers probably has crap we don't want in the client, refactor appropriately
window.helpers = require './helpers'
window.mutants = require './mutants'

# shortcuts
$w = $ window
$d = $ document

is-ie     = false or \msTransform in document.documentElement.style
is-moz    = false or \MozBoxSizing in document.documentElement.style
is-opera  = !!(window.opera and window.opera.version)
threshold = 10 # snap

#.
#### main   ###############>======-- -   -
##
#{{{ Bootstrap Mutant Common
window.mutant  = require '../lib/mutant/mutant'
window.mutate  = (e) ->
  href = $ this .attr \href
  return false unless href # guard
  return true if href?.match /#/
  search-params = {}
  History.push-state {search-params}, '', href
  false

$d.on \click 'a.mutant' window.mutate # hijack urls

History.Adapter.bind window, \statechange, (e) -> # history manipulaton
  url = History.get-page-url!replace /\/$/, ''
  $.get url, _surf:1, (r) ->
    $d.attr \title, r.locals.title if r.locals?.title # set title
    on-unload = window.mutants[window.mutator].on-unload or (w, cb) -> cb null
    on-unload window, -> # cleanup & run next mutant
      try
        window.mutant.run window.mutants[r.mutant], {locals:r.locals, window.user}
      catch e
        # do nothing
  return false
#}}}
#{{{ Scrolling behaviors
window.scroll-to-top = ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  <- $e .animate { scroll-top:$ \body .offset!top }, 140
  <- $e .animate { scroll-top:$ \body .offset!top+threshold }, 110
  <- $e .animate { scroll-top:$ \body .offset!top }, 75

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scrollTop!
  $ \body .toggle-class 'scrolled' (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 1300 # initially yield

window.awesome-scroll-to = (e, duration, on-complete) ->
  on-complete = -> noop=1 unless on-complete

  e     := $ e
  ms     = duration or 600
  offset = 100

  return unless e.length # guard
  if is-ie or is-opera
    e[0].scroll-into-view!
    on-complete!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scrollY
    if Math.abs(dst-scroll - cur-scroll) > 30
      #<- $ 'html,body' .animate { scroll-top:dst-scroll }, 140
      #<- $ 'html,body' .animate { scroll-top:dst-scroll+threshold }, 110
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms
    else
      on-complete!
  e

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

# keep human readable time up to date
time-updater = ->
  now = new Date
  $('[data-time]').each ->
    $el = $(this)
    d = new Date $el.data(\time)
    elapsed = (now - d) / 1000 # seconds
    hr = window.helpers.elapsed-to-human-readable elapsed
    $el.text hr

set-interval time-updater, 30000

# personalization ( based on parameters from user obj )
window.user <- $.getJSON '/auth/user'

# run initial mutant
window.mutant.run window.mutants[window.initial-mutant], {initial: true, window.user}

# vim:fdm=marker
