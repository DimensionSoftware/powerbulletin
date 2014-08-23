require! {
  redis
  debug
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
  RedisStore: 'socket.io/lib/stores/redis'
  ChatServer: './io-chat-server'
  Presence: './presence'
  sio: \socket.io
  pg: \./postgres
  m: \./pb-models
}

global <<< require \prelude-ls

log = debug 'io-server'

user-from-session = (s, cb) ->
  unless s?passport?user
    return cb null, {id:0, name:\Anonymous, guest:true}
  [name, site_id] = s?passport?user?split \:
  if name and site_id
    (err, user) <~ db.usr { name, site_id }
    if err
      log \user-from-session, \db.usr, err
      return cb err
    if not user
      console.log \no-user
      return cb new Error("couldn't find user")
    delete user.auths
    cb null, user
  else
    cb new Error("bad cookie #{s.passport.user}")

site-by-domain = (domain, cb) ->
  if not domain
    cb null null
  else
    db.site-by-domain domain, cb

# This is intended to be run on startup to clear stale data out of redis.
# TODO - make this less heavy handed
clear-stale-redis-data = (r, cb) ->
  r.flushall cb

@init = (server) ->
  err <- pg.init
  if err then throw err
  global.db = pg.procs

  # initialize models
  err <~ m.init
  if err then throw err

  # mixing additional keys into 'db' namespace
  do -> pg.procs <<< { [k,v] for k,v of m when k not in <[orm client driver]> }

  io  = sio.listen server
  io.set \transports, [
    * \websocket
    * \xhr-polling
    * \jsonp-polling
  ]
  io.set 'log level', 1

  redis-pub    = redis.create-client!
  redis-sub    = redis.create-client!
  redis-client = redis.create-client!
  redis-store  = new RedisStore({ redis, redis-pub, redis-sub, redis-client })
  io.set \store, redis-store

  err <- clear-stale-redis-data redis-client

  io.set \authorization, (handshake, accept) ->
    if not handshake or handshake?domain
      return accept("null handshake", false)
    handshake.domain = handshake.headers.host
    if handshake.headers.cookie
      handshake.cookies = cookie.parse handshake.headers.cookie
      connect-cookie = handshake.cookies['connect.sess']
      unless connect-cookie then return accept(null, true)
      unsigned = try
        connect.utils.parse-signed-cookie connect-cookie, cvars.secret
      catch
        console.error \connect.utils.parse-signed-cookie, e
        false

      if unsigned
        original-hash = crc32.signed unsigned
        session = try
          connect.utils.parse-JSON-cookie(unsigned) || {}
        catch
          console.error \connect.utils.parse-JSON-cookie, e
          {}
        #log \session, session
        handshake.session = session
        return accept(null, true)
      else
        #return accept("bad session?", false)
        console.warn 'bad session cookie?', connect-cookie
        return accept(null, true)
    else
      log "no cookies found during socket.io authorization phase"
      return accept(null, true)

  seen-socket-ids = {}

  io.on \connection, (socket) ->
    var search-room
    var presence

    socket.on \ok, (cb) ->
      console.warn "ok #{socket.id}"
      if cb then cb null, \ok

    console.warn { connecting: socket.id, pid: process.pid }
    if seen-socket-ids[socket.id]
      console.warn "#{socket.id} already connected"
      return
    else
      seen-socket-ids[socket.id] = 1

    if not socket
      log "no socket; bailing to prevent crash"
      return

    if not socket.handshake
      log "no socket.handshake; bailing to prevent crash"
      return

    err, user <- user-from-session socket.handshake.session
    if err
      log err
      return

    err <- db.aliases.update-last-activity-for-user user
    if err
      log err
      return

    err, site <- site-by-domain socket.handshake?domain
    if err
      log err
      return

    site-room = site.id
    user-room = "#site-room/users/#{user.id}"

    log \new-presence, site.id, socket.id
    err, presence <- new Presence site.id, socket.id

    err <- presence.enter site-room, socket.id
    if err then log \presence.enter, err
    log "joining #site-room"
    socket.join site-room
    if user?guest # logged out user
      socket.emit \logout, {}
    if user
      err <- presence.users-client-add socket.id, user
      if err then log \presence.users-client-add, err
      log "joining #user-room"
      socket.join user-room
      io.sockets.in("#{site.id}").emit \enter-site, user
      # let it fall through

    #ChatServer
    chat-server = new ChatServer(io, socket, presence, site, user)
    socket.on  \chat-message,            chat-server.message
    socket.on  \chat-between,            chat-server.between
    socket.on  \chat-unread,             chat-server.unread
    socket.on  \chat-previous-messages,  chat-server.previous-messages
    socket.on  \chat-mark-read,          chat-server.mark-read
    socket.on  \chat-mark-read-since,    chat-server.mark-read-since
    socket.on  \chat-mark-all-read,      chat-server.mark-all-read
    socket.on  \chat-past,               chat-server.past

    socket.on \disconnect, ->
      delete seen-socket-ids[socket.id]
      log \disconnected
      err <- presence.leave-all socket.id
      if err then log \presence.leave-all, err
      if search-room
        socket.leave search-room
      if user and site
        err <- db.aliases.update-last-activity-for-user user
        if err then return log \db.aliases.update-last-activity-for-user, err
        err <- presence.users-client-remove socket.id, user
        if err then return log \presence.users-client-remove, err
        err, cids <- presence.cids-by-uid user.id
        if err then return log \presence.cids-by-uid, err
        log "#{user.name}'s cids", cids
        if cids.length is 0
          io.sockets.in(site-room).emit \leave-site, user

    socket.on \ping, (data, cb) ->
      if user and site
        err <- db.aliases.update-last-activity-for-user user
        if err then return log \db.aliases.update-last-activity-for-user, err
      io.sockets.in(site-room).emit \enter-site, { user.id }
      if cb
        cb null, \pong

    socket.on \online-now, ->
      err, users <- presence.in "#{site.id}"
      unless err then try # guard
        users |> filter (-> it) |> each (u) ->
          socket.in("#{site.id}").emit \enter-site, u # not broadcast

    # client no longer needs realtime query updates (navigated away from search page)
    socket.on \search-end, ->
      if search-room
        socket.emit \debug, "leaving room: #{search-room}"
        socket.leave search-room
        search-room := null

    # client will get subscribed to said query room
    socket.on \search, (searchopts) ->
      searchopts = {} <<< searchopts # clone
      delete searchopts.page # page is irrelevant to realtime

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

    socket.on \debug, (args, cb=(->)) ->
      console.warn \debug, args
      socket.emit \debug, args
      cb null, args

    console.warn \ready, socket.id
    socket.emit \ready
