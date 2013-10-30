define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates} = require \../build/component-jade

module.exports =
  class UserEditor extends Component
    template: templates.UserEditor
# vim:fdm=marker
