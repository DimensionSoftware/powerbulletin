
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
      window.$ '#left_chrome' .show!
      window.$ '#left_content' .hide!
      window.$ '.forum .container' .masonry(
        item-selector: '.post'
        is-animated:   true
        is-fit-width:  true
        is-resizable:  true)
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
      window.$ '#left_chrome' .hide(200)
      window.$ '#left_content' .show!
      window.awesome-scroll-to \body
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
