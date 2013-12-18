require! {
  async
  debug
  redis
}

{format} = require \./server-helpers

{map} = require \prelude-ls

log = debug 'io-chat-server'

# Redis Keys
# chats-by-connection:$sid = hash conversation.id => JSON.stringify(conversation)

module.exports = class ChatServer

  (@io, @socket, @presence, @site, @user) ->
    @r = redis.create-client!

  between: (user-ids, cb=(->)) ~>
    unless @user.id in user-ids
      return cb { -success, messages: [ "You're not part of this conversation." ] }
    err, c <~ db.conversations.between @site.id, user-ids
    if err then return cb err
    cb null, c

  message: (message, cb=(->)) ~>
    err, c <~ db.conversations.select-one id: message.conversation_id
    if err then return cb err
    if not c then return cb { -success, messages: [ "No conversation" ] }
    err, c.participants <~ db.conversations.participants c.id
    if err then return cb err
    me = c.participants |> find (.user_id is message.user_id)
    if not me then return cb { -success, messages: [ "User not a participant in conversation." ] }
    err, msg <~ db.messages.upsert message
    for alias in c.participants
      @socket.in("#{@site.id}/users/#{alias.user_id}").emit \chat-message, msg
    cb null, msg
