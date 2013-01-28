require! {
 add-post : '../add-post'
 v : '../validations'
}

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
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 140
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top+threshold }, 110
    <- $ 'html,body' .animate { scroll-top:$ 'body' .offset!top }, 75

# main
# ---------
$ '#query' .focus!

$ '.forum .container' .masonry(
  item-selector: '.post'
  is-animated:   true
  is-fit-width:  true
  is-resizable:  true)

#{{{ waypoints
w.resize -> set-timeout (-> $.waypoints \refresh), 800
set-timeout (->
  $ '.forum' .waypoint {
    offset  : '33%',
    handler : (direction) ->
      e    = $ this
      e-id = e.attr \id

      # handle menu active
      id = if direction is \down then e-id else
        $ '#'+e-id .prevAll '.forum:first' .attr \id
      prev = $ 'header .menu' .find '.active'
      cur  = $ 'header .menu' .find ".#{id.replace /_/ \-}"
      prev.remove-class \active # remove old active
      cur.add-class \active     # ... and activate!

      # handle forum background
      clear-timeout w.bg-anim if w.bg-anim
      last = $ '.bg.active'
      unless last.length
        next = $ '#forum'+"_bg_#{cur.data \id}"
        next.add-class \active
      else
        w.bg-anim := set-timeout (->
          next = $ '#forum'+"_bg_#{cur.data \id}"

          last.css \top if direction is \down then -300 else 300 # stage animation
          last.remove-class \active
          next.add-class \active # ... and switch!
          next.add-class \visible # ... and switch!
          w.bg-anim = 0
        ), 300
  }), 100
#}}}

#{{{ todo non-layout-specific code (actions and view states) to relocate once mutant++ is pulled in
add-post-dialog = ->
  #xxx: stub code for now, since we have no concept of sub-forums
  # mainly here as a proof-of-concept
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

d.on \click 'header' (e) ->
  $ \body .remove-class \expanded if e.target.class-name is \header # guard
  $ '#query' .focus!
d.on \keypress '#query' -> $ \body .add-class \expanded
#}}}
# vim:fdm=marker
