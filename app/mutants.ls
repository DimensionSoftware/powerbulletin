
@homepage =
  static:
    (window, next) ->
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
