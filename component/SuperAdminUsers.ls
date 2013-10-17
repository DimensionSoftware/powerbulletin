define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./Table
  surl: \../shared/sales-urls
}
{templates} = require \../build/component-jade

module.exports =
  class SuperAdminUsers extends Component
    template: templates.SuperAdminUsers
    title: 'Edit Users'
    init: ->
      pnum-to-href = (pg) ->
        base = surl.gen(\superUsers)
        if parse-int(pg) > 1
          base + "?page=#pg"
        else
          base

      locals =
        cols: [\foo, \bar]
        rows: [[1,2],[3,4]]
        qty: 100
      @children = {table: new Table {locals, pnum-to-href} \.SuperAdminUsers-table @}
