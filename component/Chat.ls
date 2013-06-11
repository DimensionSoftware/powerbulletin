require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Chat extends Component
    @duration  = 300ms
    @easing    = \easeOutExpo
    @chats     = {}

    component-name: \Chat
    conversation: null
    template: templates.Chat

    on-attach: ~>
      @$.on \click,    \.minimize,  @minimize
      @$.on \click,    \.close,     @close
      @$.on \keydown,  \textarea,   @send-message
      console.log \attached

    on-detach: !->
      @$.find \.minimize .off!
      @$.find \.close .off!

    key: ~>
      [me,others] = [@state.me.val, @state.others.val]
      "#{me.name}/#{others.map((-> it.name)).join '/'}"

    message-from-env: ~>
      u = @state?others?val?0
      m =
        from : window.user
        to   : {id: u.id, name: u.name}
        text : @$.find('textarea').val!

    message-node: (m) ~>
      $msg = @$.find('.body > .msg').clone!
      $msg.find('.text').html m.text
      $msg.find('.from-name').html m.from.name
      $msg

    send-message: (ev) ~>
      if ev.key-code is 13
        m = @message-from-env!
        err, r <~ socket.emit \chat-message, m
        if err
          console.error err
          return
        if (@conversation is null)
          @conversation = r.conversation
        @add-message m

    add-message: (m) ~>
      $msg = @message-node m
      $messages = @$.find('.messages').append $msg
      $msg.show!
      $messages[0].scroll-top = $messages[0].scroll-height
      @$.find \textarea .val ''

    load-more-messages: (offset, limit=8) ~>
      console.debug \load-more-messages, offset, limit
      r <- $.get '/resources/chats/messages', {}

    minimize: (ev) ~>
      @$.toggle-class \minimized

    close: ~>
      console.warn \c, @
      err, r <~ socket.emit \chat-close, @conversation
      key = @key!
      console.log \key, key
      Chat.stop(@key!)

Chat.start = ([me,...others]:users) ->
  console.log \users, users
  key = map (.name), users |> join '/'
  if c = @chats[key]
    return c
  c = @chats[key] = new Chat locals: { me, others }, $('<div/>').hide!
  c.attach!
  #c.render!
  $cs = $('#chat_drawer .Chat')
  if $cs.length
    right = $cs.length * ($cs.first!width! + 8) + 8
    c.$.show!.transition({ right }, @duration, @easing)
    $('#chat_drawer').prepend(c.$)
  else
    right = 8
    c.$.show!.css({ right })
    $('#chat_drawer').prepend(c.$.show(@duration, @easing))
  c.$.find('textarea').focus!
  c

Chat.stop = (key) ->
  c = @chats[key]
  if not c then return
  <~ c.$.fade-out @duration
  c.$.remove!
  @reorganize!
  delete @chats[key]

Chat.reorganize = ->
  $cs = $('#chat_drawer .Chat')
  width = $cs.first!width!
  n = $cs.length
  $cs.each (i,e) ->
    right = (n - i - 1) * (width + 8) + 8
    $(e).transition({ right }, @duration, @easing)

Chat.client-socket-init = (socket) ->

  socket.on \chat-open, (conversation, cb) ->
    console.warn "received request to open chat #{conversation.id}"
    err, c2 <- socket.emit \chat-join, conversation
    console.log \after-chat-join, err, c2
    me-first = (a, b) ->
      | a.name is window.user?name => -1
      | otherwise                  =>  1
    people = sort-with me-first, conversation.participants
    console.log people, conversation
    names  = map (.name), people
    key    = names.join '/'
    return if Chat.chats[key]
    c = Chat.start people
    c.conversation = conversation
    c.room = c2.room

  socket.on \chat-message, (msg, cb) ~>
    return if msg.from.id is user?id
    # load appropriate chat instance
    c = Obj.find (-> it.conversation?id is msg.conversation_id), Chat.chats
    if c
      # add message to that chat
      c.add-message msg
    else
      console.warn \chat-message, 'c not found', msg

