define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates} = require \../build/component-jade

module.exports =
  class MiniSiteList extends Component
    template: templates.MiniSiteList
    init: ->

