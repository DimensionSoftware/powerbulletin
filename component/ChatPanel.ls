define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \lodash
{lazy-load-autosize, show-tooltip} = require \../client/client-helpers
{find, reverse} = require \prelude-ls

debounce = lodash.debounce _, 250ms

module.exports =
  class ChatPanel extends PBComponent

    # management of all current chats in window
    @chats = {}

    # chat-panel add if not already existing
    @add = (cid, alias, notices=0) ->
      css-id = "chat-#cid"
      panels = window.component.panels
      if @chats[css-id]
        @chats[css-id]
      else
        panels = window.component.panels
        @chats[css-id] = new ChatPanel locals: { id:css-id, uid:alias.user_id, name:alias.name, notices:notices, icon:alias.icon, width:300px, css:{}, p:panels }
        panels.add css-id, @chats[css-id]
        @chats[css-id]

    # chat-panels are autovivified via ChatPanel.add-from-message(message)
    @add-from-message = (message) ->
      id = message.conversation_id
      panels = window.component.panels
      message.user.icon = "#cache-url#{message.user.photo}"
      chat-panel = @add id, message.user
      chat-panel.add-new-message message
      if panels.selected isnt chat-panel.local \id
        t = ($ "\#icon-chat-#id .notices" .text!)
        n = if t.match /^\s*$/
          0
        else
          parse-int t
        panels.set-notice "icon-chat-#id", n+1
      chat-panel

    # add chat-panel using conversation info (but no message)
    @add-from-conversation = (c, user) ->
      #console.warn \a-c, c, user
      id     = c.id
      not-me = c.participants |> find (-> it.user_id isnt user.id) # later on, use filter
      panels = window.component.panels
      #console.log \add-from-conversation, id, icon, not-me
      not-me.icon = "#cache-url#{not-me.photo}"
      cp = @add id, not-me, c.unread
      panels.set-notice "icon-chat-#id", c.unread
      cp

    init: ->
      @seen-messages = {}
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
      @$.find \.messages .scroll (debounce @load-more-messages-scroll-handler)

    on-detach: ->
      delete @@chats[@local \id]

    cid: ~>
      (@local \id).replace /^chat-/, '' |> parse-int

    scroll-to-latest: ({animate=true,time=50ms}={}) ~>
      set-timeout (~>
        e = @$.find \.messages
        if animate
          e.animate { scroll-top: e.0.scroll-height }
        else
          e.scroll-top(e.0.scroll-height)), time # bottom

    add-new-message: (message, should-scroll) ->
      return if @seen-messages[message.id]
      @seen-messages[message.id] = 1
      if message.user_id isnt window.user.id # other chat participant has more decoration
        message
          ..other = true
          ..photo = "#cache-url/#{message.user_id}"
      $msg = @@$(jade.templates._chat_message(message))
      if should-scroll
        $msg.find \img .load (~> @scroll-to-latest {-animate})
      # FIXME only scroll if already at bottom
      near-bottom = true #Math.abs(e.offset!top - e.scroll-top!) < 15px
      @$.find \.messages .append $msg
      if near-bottom then @scroll-to-latest {-animate}

    add-old-message: (message) ->
      return if @seen-messages[message.id]
      @seen-messages[message.id] = 1
      if message.user_id isnt window.user.id # other chat participant has more decoration
        message
          ..other = true
          ..photo = "#cache-url/#{message.user_id}"
      $msg = @@$(jade.templates._chat_message(message))

      # provide a more natural infinity scroll upward
      m = @$.find \.messages
      t = m.scroll-top!
      m.prepend $msg
      h = $msg.outer-height!
      m.scroll-top t + h # return scroll to original top + prepended elements height

    message-box-key-handler: (ev) ~>
      e = @$.find \.message-box
      clear = ->
        e # clear & shrink
          ..val ''
          ..css \height \19px
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
      window.socket?emit \chat-message, message, cb

    load-initial-messages: (cb=(->)) ->
      err, r <~ socket?emit \chat-previous-messages, @id, { limit: 50 }
      if err then return err
      if r.success
        for i,msg of (reverse r.messages)
          @add-new-message msg, true
        @scroll-to-latest!
        @last-mid = r.messages[*-1]?id
        @$.find \.messages .append(@@$(jade.templates._chat_message_date msg))

    load-more-messages-scroll-handler: (ev) ~>
      scroll-top = $(ev.target).scroll-top!
      #console.info scroll-top
      return unless scroll-top <= 10
      #console.warn "id: #{@id}, last-mid: #{@last-mid}"
      err, r <~ socket?emit \chat-previous-messages, @id, { last: @last-mid }
      if r.messages.length
        for i,msg of r.messages
          @add-old-message msg
        @last-mid = r.messages[*-1].id
      else
        @scrolled-to-beginning = true

    show: ->
      if @local \virgin
        @$.transition { x: (@local \width) }, 0
        @$.css(width: @local \width)
        @$.show!
        @$.find \.message-box .css(width: (@local \width)-8px)
        @local \virgin, false
        @load-initial-messages!
      icon-id = "icon-#{@local \id}"
      socket?emit 'chat-mark-all-read', @cid!, (~> @p.set-notice(icon-id, 0))
      @p.show @$, (~>
        @scroll-to-latest!
        @$.find \.message-box .focus!)
      window.time-updater!

    hide: ->
      @p.hide @$

    resize: ->

