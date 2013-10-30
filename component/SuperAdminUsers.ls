define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./Table
}
{templates} = require \../build/component-jade

# responsible for url token superUsers
module.exports =
  class SuperAdminUsers extends Component
    template: templates.SuperAdminUsers
    title: 'Edit Users'
    init: ->
      pnum-to-href = (pg) ~>
        base = @local(\gen) \superUsers
        if parse-int(pg) > 1
          base + "?page=#pg"
        else
          base

      # table locals
      s = @state
      locals = {
        #cols: [\foo, \bar]
        #rows: [[1,2],[3,4]]
        #qty: 100
        s.cols
        s.rows
        s.qty
        s.active-page
      }
      @children = {table: new Table {locals, pnum-to-href} \.SuperAdminUsers-table @}
