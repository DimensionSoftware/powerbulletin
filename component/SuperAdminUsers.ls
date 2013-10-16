define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./Table
}
{templates} = require \../build/component-jade

module.exports =
  class SuperAdminUsers extends Component
    template: templates.SuperAdminUsers
    title: 'Edit Users'
    init: ->
      locals =
        cols: [\foo, \bar]
        rows: [[1,2],[3,4]]
        qty: 100
      @children = {table: new Table {locals} \.SuperAdminUsers-table @}
