require! {
  async
  debug
  redis
}

{format} = require \./server-helpers

{map} = require \prelude-ls

log = debug 'io-chat-server'

module.exports = class ChatServer

  (@io, @socket, @presence, @site, @user) ->
    @r = redis.create-client!

  message: (message, cb) ~>
    ## if they're not currently online, there should be some way to notify them of new messages when they do get online
    log \message, message
    ## if connection has a chat with message.chat_id use it
    err, c-json <~ @r.hget @chats-by-connection!, message.conversation_id
    if err then return cb err
    c = JSON.parse(c-json) if c-json
    if c
      log "remote chat already opened"
      err, m <~ db.conversation-add-message c.id, { user_id: message.from.id, body: message.body }
      return cb err if err
      log \m, m
      message.id = m.id
      m.body = message.body = format.chat-message message.body
      @io.sockets.in c.room .emit \chat-message, message
      cb null, { conversation: c, message: m }

    ## else load it from the database
    else
      log "need to setup new remote chat"
      err, c <~ db.conversation-find-or-create @site.id, [{id:@user.id, name:@user.name}, {id:message.to.id, name:message.to.name}]
      if err then cb err

      # join the room for the conversation if we haven't already joined
      err, c <~ @join c
      if err then return cb err

      # request a remote chat window be opened
      user-room = "#{@site.id}/users/#{message.to?id}"
      log "sending chat-open message to #user-room"
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
      set-timeout send-chat-message, 1000ms

  debug: (cb) ~>
    log \chat-debug
    @socket.emit \debug, @socket.id

