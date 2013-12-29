define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{show-tooltip} = require \../client/client-helpers

module.exports =
  class ChatPanel extends PBComponent

    # management of all current chats in window
    @chats = {}

    # chat-panels are autovivified via ChatPanel.add-message(message)
    @add-message = (message) ->
      id = message.conversation_id
      css-id = "chat-#id"
      icon = "#cache-url#{message.user.photo}"
      console.warn @chats, css-id, @chats[css-id]
      chat-panel = if @chats[css-id]
        @chats[css-id]
      else
        panels = window.component.panels
        @chats[css-id] = new ChatPanel locals: { id: css-id, icon: icon, width: 300px, css: { background: '#fff', opacity: 0.85 }, p: panels }
        panels.add id, @chats[css-id]
        @chats[css-id]
      chat-panel.add-new-message message

    init: ->
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ->
      @$.attr id: @local \id
      @$.css @css
      @$.on \keyup, \.message-box, @message-box-key-handler
      @$.find '.message-box textarea' .autosize!

    cid: ~>
      (@local \id).replace /^chat-/, '' |> parse-int

    add-new-message: (message) ->
      @$.find(\.container).append "<li>#{message.body}</li>" # TODO - do this right

    message-box-key-handler: (ev) ~>
      e = @$.find('.message-box textarea')
      if ev.key-code is 27 # close panel
        window.component.panels?off!
      if ev.key-code is 13 and not ev.shift-key
        message =
          conversation_id : @cid!
          user_id         : window.user.id
          body            : e.val!
        e # clear & shrink
          ..val ''
          ..css \height \auto
        @send-message message

    send-message: (message) ->
      window.socket.emit \chat-message, message

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.css(width: @local \width)
        @$.find \textarea .css(width: @local \width)
        @local \virgin, false
      @$.css(height: "#{hi}px")
      @p.show @$, (~> @$.find('.message-box textarea').focus!)

    hide: ->
      @p.hide @$

    resize: ->

