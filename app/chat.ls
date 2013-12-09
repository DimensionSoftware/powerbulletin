require! {
  sioa: \socket.io-announce
}

announce = sioa.create-client!

# send a message from one user to another
#
# @param  Number  c-id      conversation
# @param  Number  from-id   user id of sender
# @param  String  message   text of the message
@send = (c-id, from-id, message, cb) ->
  err, c <- db.conversations.select-one id: c-id
  if err then return cb err
  if not c then return cb new Error("conversation #c-id not found")

  err, ppl <- db.conversations.participants c-id
  if err then return cb err
  if ppl.length is 0 then return new Error("conversation #c-id has no participants")

  m =
    conversation_id : c.id
    user_id         : from-id
    body            : message

  err, r <- db.messages.upsert m
  if err then return cb err
  if not r.length then return cb new Error("db.messages.upsert failed")
  msg = r.0

  # sender of message has already seen then message.
  err, r <- db.messages.mark-read msg.id, from-id
  if err then return cb err

  for p in ppl
    announce.in("#{c.site_id}/users/#{p.user_id}").emit \chat-message, msg

  cb null, msg

# vim:fdm=indent
