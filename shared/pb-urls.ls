define = window?define or require(\amdefine) module
require, exports, module <- define


# opposite of parse
@gen = (route, catch-all-resolver) ->
  # XXX if url isn't defined below,
  # catch-all-resolver is a function (state-machine) to take the url
  # and gives back an object w/ meta data for what the url means
  # XXX different domains belong in different files (these reload browser)
  switch route
  | \superUsers => \/admin/users
  # TODO fleshing out DataRouter & Router
  | \Sales =>
    data: [\sales-menu]
    pages:
      home:
        url:  \/sales
        data: [\sales]

  | \Forum =>
    data: [\menu]
    pages:
      home:
        url:  \/
        data: [\home]
      faq:
        url: \faq
        data: [\faq]
      thread:
        data: [\form, \thread-list, \thread]
      forum:
        data: [\form, \thread-list]

@
# vim:fdm=indent
