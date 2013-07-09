require! {
  redis
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
  RedisStore: 'socket.io/lib/stores/redis'
  ChatServer: './io-chat-server'
  Presence: './presence'
  '../component/Chat'
}

user-from-session = (s, cb) ->
  unless s?passport?user
    return cb null, {id:0, name:\Anonymous, guest:true}
  [type, name, site_id] = s?passport?user?split \:
  switch type
  | \transient =>
    transient-user =
      transient: true
      transient_id: parse-int name
      rights:
        admin: true
    (err, authorized) <~ db.authorize-transient name, site_id
    if err then return cb err
    if authorized
      cb null, transient-user
    else
      cb null, null
  | \permanent =>
    (err, user) <~ db.usr {name, site_id}
    if err then return cb err
    delete user.auths
    cb err, user
  | otherwise =>
    cb new Error("bad cookie #{s.passport.user}")

site-by-domain = (domain, cb) ->
  if not domain
    cb null null
  else
    db.site-by-domain domain, cb

@init = (server) ->
  # manually reload socket.io
  keys require.cache |> filter (-> it.match /node_modules\/socket.io\//) |> each (-> delete require.cache[it])
  sio = require \socket.io

  io  = sio.listen server
  io.set 'log level', 1

  redis-pub    = redis.create-client!
  redis-sub    = redis.create-client!
  redis-client = redis.create-client!
  redis-store  = new RedisStore({ redis, redis-pub, redis-sub, redis-client })
  io.set \store, redis-store

  io.set \authorization, (handshake, accept) ->
    if handshake.headers.cookie
      handshake.cookies = cookie.parse handshake.headers.cookie
      connect-cookie = handshake.cookies['connect.sess']
      unless connect-cookie then return accept("no connect session cookie", false) # guard
      unsigned = connect.utils.parse-signed-cookie connect-cookie, cvars.secret

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
      return accept("no cookies", false)

  io.on \connection, (socket) ->
    var search-room
    var presence

    err, user <- user-from-session socket.handshake.session
    if err then console.warn err

    err, site <- site-by-domain socket.handshake.domain
    if err then console.warn err

    site-room = site.id
    user-room = "#site-room/user/#{user.id}"

    err, presence <- new Presence site.id

    err <- presence.enter site-room, socket.id
    if err then console.error \presence.enter, err
    socket.join site-room
    if user
      err <- presence.users-client-add socket.id, user
      if err then console.error \presence.users-client-add, err
      socket.join user-room
      io.sockets.in("#{site.id}").emit \enter-site, user
      # let it fall through

    #ChatServer
    chat-server = new ChatServer(io, socket, site, user)
    socket.on \chat-message, chat-server.message
    socket.on \chat-join, chat-server.join
    socket.on \chat-leave, chat-server.leave
    socket.on \chat-debug, chat-server.debug

    socket.on \disconnect, ->
      console.warn \disconnected
      if search-room
        socket.leave search-room
      if user and site
        err <- presence.leave-all socket.id
        if err then console.warn \presence.leave-all, err
        io.sockets.in(site-room).emit \leave-site, user
        chat-server.disconnect!

    socket.on \online-now, ->
      err, users <- presence.in "#{site.id}"
      users |> filter (-> it) |> each (u) ->
        console.log \u, u
        socket.in("#{site.id}").emit \enter-site, u # not braoadcast

    socket.on \debug, ->
      socket.emit \debug, socket.manager.rooms
      io.sockets.in('1/users/3').emit \debug, 'hi again to 3'

    # client no longer needs realtime query updates (navigated away from search page)
    socket.on \search-end, ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        search-room := null

    # client will get subscribed to said query room
    socket.on \search, (searchopts) ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        search-room := null

      # same thing as jquery's $.param
      param = (obj) -> ["#{k}=#{v}" for k,v of obj].join('&')

      search-room := "#{site.id}/search/#{encode-URI-component(param(searchopts))}"

      socket.emit \debug, "joining room: #{search-room}"
      socket.join search-room

      # register search with the search notifier
      io.sockets.emit \register-search, {searchopts, site-id: site.id, room: search-room}
