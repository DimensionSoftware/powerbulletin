
# XXX layout-specific client-side

threshold = 10 # snap
w = $ window

# indicate to stylus that view scrolled
has-scrolled = ->
  if w.scrollTop! > threshold
    $ 'body' .add-class 'has-scrolled'
  else
    $ 'body' .remove-class 'has-scrolled'

w.on 'scroll' -> has-scrolled!
has-scrolled!


# attach scroll-to-top
$ '.scroll-to-top' .each ->
  e = $ this
  e.attr 'title' 'Scroll to Top!'
  e.on 'mousedown' -> # bouncy scroll to top
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 100
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top+threshold }, 75
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 25
