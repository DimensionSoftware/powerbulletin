
@homepage =
  static:
    (window, next) ->
      # TODO use pre-compiled jade template
      window.render-jade 'main_content', \homepage
      next!
  on-load:
    (window, next) ->
      console.log 'client side homepage'
      next!
  on-mutate:
    (window, next) ->
      next!

@forum =
  static:
    (window, next) ->
      window.marshal('q', @q)
      window.render-jade 'left_content', \nav
      window.render-jade 'main_content', \posts
      next!
  on-initial:
    (window, next) ->
      # set initial state
      next!
  on-load:
    (window, next) ->
      console.log 'client side forum'
      next!
  on-mutate:
    (window, next) ->
      next!

@search =
  static:
    (window, next) ->
      window.marshal('q', @q)
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
