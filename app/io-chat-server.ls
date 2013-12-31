require! {
  async
  debug
}

{map} = require \prelude-ls

log = debug 'io-chat-server'

module.exports = class ChatServer

  (@io, @socket, @presence, @site, @user) ->

  between: (user-ids, cb=(->)) ~>
    unless @user.id in user-ids
      return cb { -success, messages: [ "You're not part of this conversation." ] }
    err, c <~ db.conversations.between @site.id, user-ids
    if err then return cb err
    cb null, c

  unread: (cb=(->)) ~>
    console.warn \unread
    err, unread <~ db.conversations.unread-summary-by-user @site.id, @user.id
    if err then return cb err
    cb null, unread

  message: (message, cb=(->)) ~>
    err, msg <~ db.messages.send message
    cb null, msg

# vim:fdm=indent
