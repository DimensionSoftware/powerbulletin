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
        @$.find \div:first .css(width: @local \width)
        @local \virgin, false
      @$.find \div:first .css(height: "#{hi}px")
      @p.show @$

    hide: ->
      @p.hide @$

    resize: ->

