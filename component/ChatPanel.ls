define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{show-tooltip} = require \../client/client-helpers

module.exports =
  class ChatPanel extends PBComponent

    # management of all chats
    @chats = {}

    @add-message = (message) ->
      id = message.coversation_id
      icon = "#cache-url/images/profile.jpg" # TODO - where's a good place to get this info from?
      chat-panel = if @chats[id]
        @chats[id]
      else
        panels = window.component.panels
        @chats[id] = new ChatPanel locals: { id, icon, width: 300px, css: { background: '#fff', opacity: 0.85 }, p: panels }
        panels.add id, @chats[id]
        @chats[id]
      chat-panel.add-new-message message

    init: ->
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ->
      @$.attr id: @local \id
      @$.css @css

    add-new-message: (message) ->
      @$.append "<li>#{message.body}</li>" # TODO - do this right

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

