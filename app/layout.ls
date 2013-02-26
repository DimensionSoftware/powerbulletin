# XXX layout-specific client-side

# shortcuts
$w = $ window
$d = $ document

is-ie     = false or \msTransform in document.documentElement.style
is-moz    = false or \MozBoxSizing in document.documentElement.style
is-opera  = !!(window.opera and window.opera.version)
threshold = 10 # snap

# main
# ---------
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

# header expansion
$d.on \click 'header' (e) ->
  $ \body .remove-class \expanded if e.target.class-name.index-of(\toggler) > -1 # guard
  $ '#query' .focus!
$d.on \keypress '#query' -> $ \body .add-class \expanded


# vim:fdm=marker
