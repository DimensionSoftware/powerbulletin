define = window?define or require(\amdefine) module
require, exports, module <- define

#TODO: create a high-level abstraction so we only have to define a components layout properties once
#      but still provide the same array interface to module.exports
module.exports =
  homepage    : [\Sales, \SalesLayout, \.SalesLayout-content]
  super       : [\SuperAdmin, \SalesLayout, \.SalesLayout-content]
  super-sites : [\SuperAdmin, \SalesLayout, \.SalesLayout-content]
  super-users : [\SuperAdmin, \SalesLayout, \.SalesLayout-content]
  # page oriented ^^
  # o

# we want to command the layout aka  showToolbar hideToolbar

# what info do we need to map this stuff together?

# module.exports =
#   # shows toolbar
#   homepage-foo:
#     klass: \SalesApp
#     layout: \SalesLayout
#   # doesn't show toolbar
#   homepage-bar:
#     layout: \SalesLayout
#     children:
#       * klass: \SalesApp
#         root: \#bar

# vim:fdm=indent
