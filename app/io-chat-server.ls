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

  between: (user-ids, cb) ~>
    unless @user.id in user-ids
      return cb { -success, messages: [ "You're not part of this conversation." ] }
    err, c <~ db.conversations.between @site.id, user-ids
    if err then return cb err
    cb null, c

  message: (message, cb) ~>
    # TODO
    cb null
