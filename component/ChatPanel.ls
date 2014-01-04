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
    @add = (cid, alias) ->
      css-id = "chat-#cid"
      panels = window.component.panels
      if @chats[css-id]
        @chats[css-id]
      else
        panels = window.component.panels
        @chats[css-id] = new ChatPanel locals: { id:css-id, uid:alias.user_id, name:alias.name, icon:alias.icon, width:300px, css:{}, p:panels }
        panels.add css-id, @chats[css-id]
        @chats[css-id]

    # chat-panels are autovivified via ChatPanel.add-from-message(message)
    @add-from-message = (message) ->
      id = message.conversation_id
      message.user.icon = "#cache-url#{message.user.photo}"
      chat-panel = @add id, message.user
      chat-panel.add-new-message message
      chat-panel

    # add chat-panel using converstation info (but no message)
    @add-from-conversation = (c, user) ->
      #console.warn \a-c, c, user
      id     = c.id
      not-me = c.participants |> find (-> it.user_id isnt user.id) # later on, use filter
      #console.log \add-from-conversation, id, icon, not-me
      not-me.icon = "#cache-url#{not-me.photo}"
      @add id, not-me

    init: ->
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true
      @id = (@local \id).replace(/chat-/, '')

    on-attach: ->
      @$.add-class \panel
      @$.attr id: @local \id
      @$.css @css
      @$.on \keyup, \.message-box, @message-box-key-handler
      @$.on \keydown, \.message-box, -> if it.key-code is 13 and not it.shift-key then false # eat returns
      <~ lazy-load-autosize
      @$.find \.message-box .autosize!

    cid: ~>
      (@local \id).replace /^chat-/, '' |> parse-int

    scroll-to-latest: ~>
      set-timeout (~>
        e = @$.find \.messages
        e.scroll-top(e.0.scroll-height)), 50ms # bottom

    add-new-message: (message) ->
      $msg = @@$(jade.templates._chat_message(message))
      if message.user_id isnt window.user.id
        $msg.add-class \other
      e = @$.find \.messages
      # FIXME only scroll if already at bottom
      should-scroll = true #Math.abs(e.offset!top - e.scroll-top!) < 15px
      @$.find(\.messages).append $msg
      if should-scroll then @scroll-to-latest!

    message-box-key-handler: (ev) ~>
      e = @$.find \.message-box
      clear = ->
        e # clear & shrink
          ..val ''
          ..css \height \14px
      if ev.key-code is 27 # close panel
        window.component.panels?off!
      if ev.key-code is 13 and not ev.shift-key
        v = e.val!
        if v.match /^\n*$/ then clear!; return false # guard
        message =
          conversation_id : @cid!
          user_id         : window.user.id
          body            : v
        clear!
        @send-message message

    send-message: (message, cb=(->)) ->
      window.socket.emit \chat-message, message, cb

    load-initial-messages: (cb=(->)) ->
      url = "/resources/conversations/#{@id}"
      @@$.get url, { limit: 20 }, (r) ~>
        console.log \msgs, r
        if r.success
          for i,msg of r.messages
            @add-new-message msg

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.css(width: @local \width)
        @$.find \.message-box .css(width: (@local \width)-8px)
        @local \virgin, false
        @load-initial-messages!
      @$.css(height: "#{hi}px")
      @p.show @$, (~> @$.find \.message-box .focus!)
      @scroll-to-latest!

    hide: ->
      @p.hide @$

    resize: ->

