define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \lodash
{lazy-load-autosize, show-tooltip} = require \../client/client-helpers
{find, reverse} = require \prelude-ls

debounce = lodash.debounce _, 250ms

module.exports =
  class ChatList extends PBComponent

    init: ~>
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ~>
      @$.hide!

    on-detach: ~>

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.css(width: @local \width)
        @local \virgin, false
      @$.css(height: "#{hi}px")
      @p.show @$

    hide: ->
      @p.hide @$
