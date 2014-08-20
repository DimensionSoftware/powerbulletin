define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{lazy-load-autosize, show-tooltip} = require \../client/client-helpers
{find, reject} = require \prelude-ls

module.exports =
  class ChatList extends PBComponent

    init: ~>
      @p = @local \p
      @css = @local(\css) || {}
      @css.display = \none
      @local \virgin, true

    on-attach: ~>
      @$.add-class \panel
      @$.hide!
      @$.on \click, \.chat, @select-chat-panel-handler
      @@$R((socket) ~> @load-initial!).bind-to(window.r-socket)

    on-detach: ~>

    add: (c) ~>
      c.others = c.participants |> reject (-> it.user_id is window.user?id)
      $chat = @@$(jade.templates._chat_list_item(c))
      @$.find \.list .append $chat

    load-initial: ~>
      err, chats <~ socket.emit \chat-past
      @chats = chats
      if err then return err
      if chats.length
        unless window.admin-chats
          if window.user?rights?super then @@$ \.onclick-messages .show!
        else
          @@$ \.onclick-messages .show!
        @$.find \.list .html '' # clear
        for i,c of chats
          @add c

    select-chat-panel-handler: (ev) ~>
      id = $(ev.current-target).data \id
      c = find (-> it.id is id), @chats
      panel = ChatPanel.add-from-conversation c, window.user
      @p.select panel.local \id

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.transition { x: (@local \width) }, 0
        @$.css(width: @local \width)
        @$.show!
        @local \virgin, false
      @$.css(height: "#{hi}px")
      @p.show @$
      window.time-updater!

    hide: ->
      @p.hide @$

# vim:fdm=indent
