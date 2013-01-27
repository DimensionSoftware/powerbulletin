
# XXX layout-specific client-side

# shortcuts
w = $ window
d = $ document

threshold = 10 # snap

# indicate to stylus that view scrolled
has-scrolled = ->
  st = w.scrollTop!
  $ 'body' .toggle-class 'has-scrolled' (st > threshold)

set-timeout (->
  w.on 'scroll' -> has-scrolled!
  has-scrolled!), 1300 # initially yield

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

$ '.forum .container' .masonry(
  item-selector: '.post'
  is-animated:   true
  is-fit-width:  true
  is-resizable:  true)

# add waypoints
set-timeout (->
  $ '.forum' .waypoint {
    offset  : '33%',
    handler : (direction) ->
      e = $ this

      # handle menu active
      id  = e.attr \id
      cur = if direction is \down then id else
        $ '#'+id .prevAll '.forum:first' .attr \id # prev
      $ 'header .menu' .find '.active' .removeClass \active             # remove old active
      $ 'header .menu' .find ".#{cur.replace /_/ \-}" .addClass \active # ... and activate!

    # TODO handle background 3dfx
  }), 100

#{{{ todo non-layout-specific code (actions and view states) to relocate once mutant++ is pulled in
add-post-dialog = ->
  #xxx: stub code for now, since we have no concept of sub-forums
  # mainly here as a proof-of-concept
  $ 'header' .toggle-class \expanded
  fid = $(this).data \fid

  post-html = '<h1>add post form goes here</h1>'
  html <- $.get '/ajax/add-post', {fid}
  $(html).dialog modal: true
  false # stop event propagation

# assumes immediate parent is form (in case of submit button)
add-post = ->
  form = $ '#add-post-form'
  $.post '/ajax/add-post', form.serialize!, ->
    console.log 'success! post added'
    console.log 'stub: do something fancy to confirm submission'

  false # stop event propagation
# delegated events
d.on \click '#add-post-submit' add-post
d.on \click '.onclick-add-post-dialog' add-post-dialog

d.on \click 'header' -> $ \header .remove-class \expanded
d.on \keypress '#query' -> $ \header .add-class \expanded
#}}}
# vim:fdm=marker
