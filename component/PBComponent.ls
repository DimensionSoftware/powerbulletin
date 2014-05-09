define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates} = require \../build/component-jade

# XXX PBComponent wraps all PB concerns:
# - keeping Component general
# - shrinking boilerplate for instances of PBComponent

module.exports =
  class PBComponent extends Component
    template: ->
      # default jade templates
      tpl-name = @constructor.display-name
      fn = templates[tpl-name]
      if fn then fn @locals! else ''

# vim: fdm=marker
