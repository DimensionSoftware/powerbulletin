require! {
  redis
  async
}

# Important Redis Keys
#
# users - a cid to user mapping; contains JSON strings
# rooms:$cid - a cid to room mapping; value is a set of room names as strings
# $room - room names are arbitrary strings; value is a set of cids

module.exports = class Presence
  (@site-id, cb) ->
    @r = redis.create-client!
    @r.select @site-id, cb

  # who is in a channel -- list of connection ids, user ids tuples
  in: (room, cb) ~>
    (err, cids) <~ @r.smembers room
    if err then return cb err
    return cb null, [] if cids.length is 0
    (err, users-json) <~ @r.hmget \users, ...cids
    if err then return cb err
    cb null (users-json |> map -> JSON.parse it)

  # enter a room
  enter: (room, cid, cb) ~>
    tasks =
      r  : @r.sadd room, cid, _
      rc : @r.sadd "rooms:#{cid}", room, _
    async.auto tasks, cb

  # leave a room
  leave: (room, cid, cb) ~>
    tasks =
      r  : @r.srem room, cid, _
      rc : @r.srem "rooms:#{cid}", room, _
    async.auto tasks, cb

  # leave all rooms a connection is using.  useful for disconnection.
  # also deletes rooms:$cid key
  leave-all: (cid, cb) ~>
    (err, rooms) <~ @rooms-by-cid cid
    async.each rooms, ((room, cb) ~> @leave room, cid, cb), cb

  # rooms a connection is in
  rooms-by-cid: (cid, cb) ~>
    @r.smembers "rooms:#{cid}", cb

  # TODO socket.io connection ids associated to a user
  cids-by-users: (users, cb) ~>

  # associate a user with a connection
  users-client-add: (cid, user, cb) ~>
    @r.hset \users, cid, JSON.stringify(user), cb

  # disassociate a user with a connection
  users-client-remove: (cid, cb) ~>
    @r.hrem \users, cid, cb
