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
      tmpl = if fn then fn @locals! else ''
      # XXX - I am confused.  When I click on "Login", the following line prints the right thing.
      # XXX - However, the browser shows the old social links instead of the ones that go to pb.com.
      console.log \this-seems-right-but, tmpl
      tmpl

# vim: fdm=marker
