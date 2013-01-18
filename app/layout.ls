
# XXX layout-specific client-side

threshold = 10 # snap
w = $ window

# indicate to stylus that view scrolled
has-scrolled = ->
  st = w.scrollTop!
  $ 'body' .toggle-class 'has-scrolled' (st > threshold)

setTimeout (->
  w.on 'scroll' -> has-scrolled!
  has-scrolled!), 1000 # initially yield

# attach scroll-to-top
$ '.scroll-to-top' .each ->
  e = $ this
  e.attr 'title' 'Scroll to Top!'
  e.on 'mousedown' -> # bouncy scroll to top
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 100
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top+threshold }, 85
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 35

# main
$ '#query' .focus!
