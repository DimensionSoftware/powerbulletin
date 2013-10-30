define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./Paginator
}
{templates} = require \../build/component-jade

module.exports =
  class Table extends Component
    ({@pnum-to-href} = {}) ->
      super ...

    template: templates.Table
    init: ->
      # mandatory variables

      # passed directly to Paginator child
      @local \activePage, 1 unless @local(\activePage)
      @local \qty, 0 unless @local(\qty)
      @local \step, 8 unless @local(\step)

      # specific to this component
      @local \cols, [] unless @local(\cols)
      @local \rows, [] unless @local(\rows)

      s = @state # shortcut

      do ~>
        locals = {s.active-page, s.qty, s.step}
        @children = {paginator: new Paginator({locals, @pnum-to-href}, \.Table-paginator, @)}

      # most naive update routine possible :D
      ignore = false
      @@$R((active-page, qty, step, cols, rows) ~>
        unless ignore # avoid stack explosion
          ignore := true
          @reload!
          ignore := false
      ).bind-to @state.active-page, @state.qty, @state.step, @state.cols, @state.rows

## repl hackery:
# require! \./component/Table; t = new Table {locals: {qty: 100, step: 8, cols: {foo: \FooHeader}, rows: [{foo: 1}, {foo: 2}]}}; t.html!
# t.local(\qty, 0)
## html should be different now since qty set to 0, no reload required
# t.html!
