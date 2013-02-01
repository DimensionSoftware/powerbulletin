
@homepage =
  static:
    (window, next) ->
      # TODO use pre-compiled jade template
      console.log 'before jade'
      window.render-jade 'content', \homepage
      next!
  on-load:
    (window, next) ->
      next!
  on-mutate:
    (window, next) ->
      next!

@forum =
  static:
    (window, next) ->
      window.marshal('q', @q)
      next!
  on-initial:
    (window, next) ->
      # set initial state
      next!
  on-load:
    (window, next) ->
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
