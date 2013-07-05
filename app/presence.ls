require! {
  redis
}

module.exports = class Presence
  (@site-id, cb) ->
    @r = redis.create-client!
    @r.select @site-id, cb

  # who is in a channel -- list of connection ids, user ids tuples
  in: (room, cb) ~>
    (err, cids) <~ @r.smembers room
    if err then return cb err
    (err, users-json) <~ @r.hmget \users, ...cids
    if err then return cb err
    cb null (users-json |> map -> JSON.parse it)

  # enter a room
  enter: (room, cid, cb) ~>
    @r.sadd room, cid, cb

  # leave a room
  leave: (room, cid, cb) ~>
    @r.srem room, cid, cb

  # TODO socket.io connection ids associated to a user
  cids-by-users: (users, cb) ~>

  # associate a user with a connection
  user-add-client: (user, cid, cb) ~>
    @r.hset \users, cid, JSON.stringify(user), cb

  # disassociate a user with a connection
  user-remove-client: (cid, cb) ~>
    @r.hrem \users, cid, cb
