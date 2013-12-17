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

    # management of all chats
    @chats = {}

    @find = (c-id) ->
      if @chats[c-id]
        @chats[cid]
      else
        @chats[cid] = new ChatPanel

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
        @$.css(width: @local \width)
        @$.find \textarea .css(width: @local \width)
        @local \virgin, false
      @$.css(height: "#{hi}px")
      @p.show @$

    hide: ->
      @p.hide @$

    resize: ->


    @client-socket-init = (socket) ->
      socket.on \chat-message, (message, cb) ->
        # do we have a panel for the conversation this message belongs to?
        # if not, create one
        # show the panel
        # add the message to the chat panel

