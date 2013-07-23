require! {
  redis
  async
}

# Important Redis Keys
#
# users - a cid to user mapping; contains JSON strings
# rooms:$cid - a cid to room mapping; value is a set of room names as strings
# cids:$uid - a uid to cids mapping; value is a set of cids being used by a user
# $room - room names are arbitrary strings; value is a set of cids

module.exports = class Presence

  # per-process data to assist clean up in the event of a crashed process
  @cids-by-site = {}

  # this is run after a process dies to remove the data the process put into redis
  @clean-up = (cb=(->)) ->
    #console.error \cids-by-site, @cids-by-site
    for site-id in keys @cids-by-site
      for c in keys @cids-by-site[site-id]
        do -> # needed a "lexical" scope
          cid = c
          #console.warn "#site-id #cid"
          p = new Presence site-id, cid
          err, user <- p.user cid
          #console.warn \user, err, user
          if err then return cb(err)
          err <- p.leave-all cid
          #console.warn \leave-all, err
          if err then return cb(err)
          #console.warn \delete-user-maybe
          if user
            err <- p.users-client-remove cid, user
            cb err
          else
            cb null

  # constructor
  (@site-id, @cid=0, cb=(->)) ->
    @r = redis.create-client!
    err <~ @r.select @site-id
    @@cids-by-site[@site-id] ||= {}
    @@cids-by-site[@site-id][@cid] = 1
    cb err, @

    # XXX 2013-07-22 I added @cid to make clean up easier only to realize so many
    # methods already take cid as a parameter.  They technically don't have to
    # anymore, but I don't want to change it now.

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
    delete @@cids-by-site[@site-id][cid]
    (err, rooms) <~ @rooms-by-cid cid
    if err then return cb err
    (err) <~ async.each rooms, ((room, cb) ~> @leave room, cid, cb)
    (err) <~ @r.del "rooms:#{cid}"
    @r.hdel \users, cid, cb

  # rooms a connection is in
  rooms-by-cid: (cid, cb) ~>
    @r.smembers "rooms:#{cid}", cb

  # socket.io connection ids associated with a user
  cids-by-uid: (uid, cb) ~>
    @r.smembers "cids:#{uid}", cb

  # associate a user with a connection
  users-client-add: (cid, user, cb) ~>
    @r.multi!
      .hset \users, cid, JSON.stringify(user)
      .sadd "cids:#{user.id}", cid
      .exec cb

  # disassociate a user with a connection
  users-client-remove: (cid, user, cb) ~>
    @r.multi!
      .srem "cids:#{user.id}", cid
      .hdel \users, cid
      .exec cb

  user: (cid, cb) ->
    (err, user-json) <~ @r.hget \users, cid
    if err then return cb err
    cb null, JSON.parse(user-json)

process.on "SIGINT", ->
  console.error "SIGINT CAUGHT - cleaning up connections belonging to process #{process.id}"
  err <- Presence.clean-up
  process.exit!
