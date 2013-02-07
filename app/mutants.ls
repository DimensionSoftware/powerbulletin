
layout-static = (w, mutator) ->
  # indicate current
  w.marshal \mutator, mutator     # js
  w.$ \html .attr(\class mutator) # stylus


@homepage =
  static:
    (window, next) ->
      window.render-jade 'main_content' \homepage
      layout-static window, \homepage
      next!
  on-load:
    (window, next) ->
      window.$ '.forum .container' .masonry(
        item-selector: '.post'
        is-animated:   true
        is-fit-width:  true
        is-resizable:  true)
      #{{{ Waypoints
      set-timeout (->
        # sticky forum headers
        $ = window.$
        $ '.forum .header' .waypoint \sticky { offset: -100 }

        # forum switches
        $ '.forum' .waypoint {
          offset  : '33%',
          handler : (direction) ->
            e   = $ this
            eid = e.attr \id

            # handle menu active
            id = if direction is \down then eid else
              $ '#'+eid .prevAll '.forum:first' .attr \id
            return unless id # guard
            $ 'header .menu' .find '.active' .remove-class \active # remove prev
            cur  = $ 'header .menu'
              .find ".#{id.replace /_/ \-}"
              .add-class \active # ...and activate!

            # handle forum headers
            $ '.forum .invisible' .remove-class \invisible
            $ '.forum .stuck'     .remove-class \stuck
            # TODO if direction is \up stick last forum

            # handle forum background
            $ '.bg' .each -> $ this .remove!prependTo $ 'body' # position behind
            clear-timeout window.bg-anim if window.bg-anim
            last = $ '.bg.active'
            unless last.length
              next = $ '#forum'+"_bg_#{cur.data \id}"
              next.add-class \active
            else
              window.bg-anim := set-timeout (->
                next = $ '#forum'+"_bg_#{cur.data \id}"

                last.css \top if direction is \down then -300 else 300 # stage animation
                last.remove-class \active
                next.add-class 'active visible' # ... and switch!
                window.bg-anim = 0
              ), 300
        }), 100
      #}}}
      next!
  on-unload:
    (window, next) ->
      window.$ '.forum .container' .masonry(\destroy)
      window.$ '.forum .header' .waypoint(\destroy)
      window.$ '.forum' .waypoint(\destroy)
      next!

@forum =
  static:
    (window, next) ->
      window.render-jade 'left_content' \nav
      window.render-jade 'main_content' \posts
      layout-static window, \forum
      next!
  on-load:
    (window, next) ->
      next!
  on-mutate:
    (window, next) ->
      window.awesome-scroll-to \body 300
      next!

@search =
  static:
    (window, next) ->
      next!
  on-load:
    (window, next) ->
      next!
  on-initial:
    (window, next) ->
      # set initial state
      next!
  on-mutate:
    (window, next) ->
      next!

# vim:fdm=marker
