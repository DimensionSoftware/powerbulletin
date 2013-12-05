require! {
  sioa: \socket.io-announce
}

announce = sioa.create-client!

# send a message from one user to another
#
# @param  Number  c-id      conversation
# @param  Number  from-id   user id of sender
# @param  Number  to-id     user id of recipient
# @param  String  message   text of the message
@send = (c-id, from-id, to-id, message, cb) ->
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

  err, m <- db.messages.upsert m
  if err then return cb err

  for p in ppl
    announce.in("#{c.site_id}/user/#{p.user_id}").emit \chat-message, m

  cb null, m

# vim:fdm=indent
