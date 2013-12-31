define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{lazy-load-autosize, show-tooltip} = require \../client/client-helpers
{find} = require \prelude-ls

module.exports =
  class ChatPanel extends PBComponent

    # management of all current chats in window
    @chats = {}

    # chat-panel add if not already existing
    @add = (id, icon, name) ->
      css-id = "chat-#id"
      panels = window.component.panels
      if @chats[css-id]
        @chats[css-id]
      else
        panels = window.component.panels
        @chats[css-id] = new ChatPanel locals: { id: css-id, name: name, icon: icon, width: 300px, css:{}, p: panels }
        panels.add id, @chats[css-id]
        @chats[css-id]

    # chat-panels are autovivified via ChatPanel.add-message(message)
    @add-message = (message) ->
      id = message.conversation_id
      icon = "#cache-url#{message.user.photo}"
      chat-panel = @add id, icon, message.user.name
      chat-panel.add-new-message message
      chat-panel

    # add chat-panel using converstation info (but no message)
    @add-conversation = (c, user) ->
      console.warn \a-c, c, user
      id     = c.id
      not-me = c.participants |> find (-> it.user_id isnt user.id) # later on, use filter
      icon   = "#cache-url#{not-me.photo}"
      console.log \add-conversation, id, icon, not-me
      @add id, icon, not-me.name

    init: ->
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ->
      @$.attr id: @local \id
      @$.css @css
      @$.on \keyup, \.message-box, @message-box-key-handler
      <~ lazy-load-autosize
      @$.find \.message-box .autosize!

    cid: ~>
      (@local \id).replace /^chat-/, '' |> parse-int

    add-new-message: (message) ->
      $msg = @@$(jade.templates._chat_message(message))
      if message.user_id isnt window.user.id
        $msg.add-class \other
      @$.find(\.messages).append $msg

    message-box-key-handler: (ev) ~>
      e = @$.find \.message-box
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
        @$.find \.message-box .css(width: @local \width)
        @local \virgin, false
      @$.css(height: "#{hi}px")
      @p.show @$, (~> @$.find \.message-box .focus!)

    hide: ->
      @p.hide @$

    resize: ->

