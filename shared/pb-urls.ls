define = window?define or require(\amdefine) module
require, exports, module <- define

# opposite of parse
@gen = (route) ->
  switch route
  | \superUsers => \/admin/users

@
# vim:fdm=indent
