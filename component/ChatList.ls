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
      @$.hide!
      @$.on \click, \.chat, @select-chat-panel-handler

    on-detach: ~>

    add: (c) ~>
      c.others = c.participants |> reject (-> it.user_id is window.user.id)
      $chat = @@$(jade.templates._chat_list_item(c))
      @$.find \.list .append $chat

    load-initial: ~>
      err, chats <~ socket.emit \chat-past
      @chats = chats
      console.log @chats
      if err then return err
      console.warn chats
      for i,c of chats
        @add c

    select-chat-panel-handler: (ev) ~>
      #console.log \ev, ev
      id = $(ev.current-target).data \id
      c = find (-> it.id is id), @chats
      #console.log \c, c
      ChatPanel.add-from-conversation c

    show: ->
      hi = $(window).height!
      if @local \virgin
        @$.css(width: @local \width)
        @local \virgin, false
        @load-initial!
      @$.css(height: "#{hi}px")
      @p.show @$

    hide: ->
      @p.hide @$

# vim:fdm=indent
