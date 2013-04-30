require! {
  sio: 'socket.io'
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
  RedisStore: 'socket.io/lib/stores/redis'
  redis: 'socket.io/node_modules/redis'
}

# might need to put this somewhere more persistent
@state = {}

enter-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  @state[s].users[user.name] = u = { id: user.id, name: user.name }
  socket.join(s)
  socket.in(s).broadcast.emit \enter-site, u

leave-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  delete @state[s].users[user.name]
  socket.leave(s)
  console.log "leaving #{s}"
  socket.in(s).broadcast.emit \leave-site, { id: user.id, name: user.name }

in-site = (socket, site) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  users = keys @state[s].users
  users.for-each (name) ~>
    u = @state[s].users[name]
    console.warn \enter-site, \on-connect, u
    socket.in(s).emit \enter-site, u # not braoadcast

user-from-session = (s, cb) ->
  unless s?passport?user
    return cb 'invalid session', null
  [name, site_id] = s?passport?user?split \:
  #console.warn "deserialize", name, site_id
  (err, user) <- db.usr {name, site_id}
  cb err, user

site-by-domain = (domain, cb) ->
  if not domain
    cb null null
  else
    db.site-by-domain domain, cb

@init = (server) ->
  io = sio.listen server
  io.set 'log level', 1

  redisPub    = redis.create-client!
  redisSub    = redis.create-client!
  redisClient = redis.create-client!
  redisStore  = new RedisStore({ redis, redisPub, redisSub, redisClient })
  io.set \store, redisStore

  io.set \authorization, (handshake, accept) ->
    if handshake.headers.cookie
      handshake.cookies = cookie.parse handshake.headers.cookie
      unsigned = connect.utils.parse-signed-cookie handshake.cookies['connect.sess'], cvars.secret

      if unsigned
        original-hash = crc32.signed unsigned
        session = connect.utils.parse-JSON-cookie(unsigned) || {}
        #console.log \session, session
        handshake.session = session
        handshake.domain  = handshake.headers.host
        return accept(null, true)
      else
        return accept("bad session?", false)
    else
      return accept("no cookie", false)

  io.on \connection, (socket) ->
    var search-room

    err, user <- user-from-session socket.handshake.session
    if err then console.warn err

    err, site <- site-by-domain socket.handshake.domain
    if err then console.warn err

    if user and site
      #console.warn { site: site.name, user: user.name }
      enter-site socket, site, user
    if site
      #console.warn { site: site.name }
      in-site socket, site

    socket.on \disconnect, ->
      console.warn \disconnected
      if user and site
        leave-site socket, site, user

    socket.on \online-now, ->
      if site
        in-site socket, site

    socket.on \debug, ->
      socket.emit \debug, 'hi'
      socket.emit \debug, socket.manager.rooms
      socket.in('1').emit \debug, 'hi again to 1'

    # client will get subscribed to said query room
    socket.on \search, (q) ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        console.warn 'MADE IT!'

      search-room := "#{site.id}/q/#{encode-URI-component(q.to-lower-case!)}"
      socket.emit \debug, "joining room: #{search-room}"
      socket.join search-room

      # register search with the search notifier
      io.sockets.emit \register-search, {q, site-id: site.id, room: search-room}
