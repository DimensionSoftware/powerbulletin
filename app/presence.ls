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
  (@site-id, cb=(->)) ->
    @r = redis.create-client!
    err <~ @r.select @site-id
    cb err, @

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
    @r.multi!
      .sadd room, cid
      .sadd "rooms:#{cid}", room
      .exec cb

  # leave a room
  leave: (room, cid, cb) ~>
    @r.multi!
      .srem room, cid
      .srem "rooms:#{cid}", room
      .exec cb

  # leave all rooms a connection is using.  useful for disconnection.
  # also deletes rooms:$cid key
  leave-all: (cid, cb) ~>
    (err, rooms) <~ @rooms-by-cid cid
    if err then return cb err
    (err) <~ async.each rooms, ((room, cb) ~> @leave room, cid, cb)
    @r.del "rooms:#{cid}", cb

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

# vim:fdm=indent
