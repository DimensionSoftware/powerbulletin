define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates}    = require \../build/component-jade
{show-tooltip} = require \../client/client-helpers

module.exports =
  class ChatPanel extends Component
    template: templates.ChatPanel

    init: ->
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ->
      @$.attr id: @local \id
      @$.css @css

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.find \div:first .css(width: @local \width)
        @local \virgin, false
      @$.find \div:first .css(height: "#{hi - 27}px")
      @p.show @$

    hide: ->
      @p.hide @$

    resize: ->

