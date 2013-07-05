module.exports = class Presence
  (@redis, @site-id) ->
    # @redis.select @site-id

  # who is in a channel
  in: (room, cb) ~>

  # enter a room
  enter: (room, cid, cb) ~>

  # leave a room
  leave: (room, cid, cb) ~>

  # user by connection id
  user-by-cid: (cid, cb) ~>

  # socket.io connection ids associated to a user
  cids-by-user-id: (user-id, cb) ~>

  # associate a user with a connection
  user-add-client: (user-id, cid, cb) ~>

  # disassociate a user with a connection
  user-remove-client: (user-id, cid, cb) ~>
