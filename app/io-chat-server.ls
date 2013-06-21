module.exports = class ChatServer

  (@io, @socket, @site, @user) ->

  connections: {} # XXX - may need to move this to redis

  join: (c, cb) ~>
    console.warn \chat-join
    c.room = "#{@site.id}/conversations/#{c.id}"
    @connections[@socket.id] ||= {}
    @connections[@socket.id][c.id] = c
    @socket.join c.room
    cb null, c

  disconnect: ~>
    # leave all user's chats
    console.warn \chat-disconnect
    for c in keys @connections[@socket.id]
      @chat-leave {id:c, room:"#{@site.id}/conversations/#c"}, (->)

  leave: (c, cb) ~>
    console.warn \chat-leave
    #console.warn \socket-id, @socket.id
    #console.warn \connections, @connections
    delete @connections[@socket.id]?[c.id]
    @socket.leave c?room
    cb null, c

  message: (message, cb) ~>
    ## if connection has a chat with message.chat_id use it
    if c = @connections[@socket.id]?[message.conversation_id]
      console.warn "remote chat already opened"
      err, m <~ db.conversation-add-message c.id, { user_id: message.from.id, body: message.body }
      return cb err if err
      message.id = m.id
      m.body = message.body = format.chat-message message.body
      @io.sockets.in c.room .emit \chat-message, message
      cb null, { conversation: c, message: m }

    ## else load it from the database
    else
      console.warn "need to setup new remote chat"
      err, c <~ db.conversation-find-or-create [{id:@user.id, name:@user.name}, {id:message.to.id, name:message.to.name}]
      if err then cb err

      # join the room for the conversation if we haven't already joined
      c.room = "#{@site.id}/conversations/#{c.id}"
      @connections[@socket.id] ||= {}
      @connections[@socket.id][c.id] = c
      @socket.join c.room

      # request a remote chat window be opened
      user-room = "#{@site.id}/users/#{message.to?id}"
      @io.sockets.in(user-room).emit \chat-open, c

      # broadcast message to channel after delay
      send-chat-message = ~>
        message.conversation_id = c.id
        err, m <~ db.conversation-add-message c.id, { user_id: message.from.id, body: message.body }
        return cb err if err
        message.id = m.id
        m.body = message.body = format.chat-message message.body
        @io.sockets.in(c.room).emit \chat-message, message
        cb null, { conversation: c, message: m }
      set-timeout send-chat-message, 100ms

  debug: (cb) ~>
    console.warn \chat-debug
    @socket.emit \debug, @connections
    @socket.emit \debug, @socket.id

