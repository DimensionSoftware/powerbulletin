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

  # summary of unread messages grouped by conversation
  unread: (cb=(->)) ~>
    err, unread <~ db.conversations.unread-summary-by-user @site.id, @user.id
    if err then return cb err
    cb null, unread

  # send a message
  message: (message, cb=(->)) ~>
    err, msg <~ db.messages.send message
    cb null, msg

  # previous messages
  previous-messages: (cid, {last=null,limit=30}, cb=(->)) ~>
    err, c <~ db.conversations.by-id cid
    if err then return cb { -success, err }
    if c
      may-participate = any (~> it.user_id is @user.id), c.participants
      unless may-participate
        return cb { -success, errors: [ "#{@user.id} is not a participant of cid #cid" ] }
      err, messages <~ db.messages.by-cid cid, @user.id, last, limit
      if err then return cb { -success, err }
      c.messages = messages
      c.success = true
      return cb null, c
    else
      return cb { -success }

  # mark one message unread for @user
  mark-read: (mid, cb=(->)) ~>
    err <~ db.messages.mark-read mid, @user.id
    cb err, { success: !!err }

  # mark all messages read for combination of cid and @user.id
  mark-read-since: (mid, cid, cb=(->)) ~>
    err <~ db.messages.mark-read-since mid, cid, @user.id
    cb err, { sucess: !!err }

  # figure out the first unread message and mark all read
  mark-all-read: (cid, cb=(->)) ~>
    err <~ db.messages.mark-all-read cid, @user.id
    cb err, { sucess: !!err }

  # info on past conversations
  past: (cb=(->)) ~>
    db.conversations.past @site.id, @user.id, cb

# vim:fdm=indent
