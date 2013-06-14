require! {
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
  RedisStore: 'socket.io/lib/stores/redis'
  redis: 'socket.io/node_modules/redis'
  '../component/Chat'
}

# might need to put this somewhere more persistent
@state = {} # XXX - may need to move this to redis

# I might move this to another file later.
# I'm just not sure where in the dir hierarchy it should go.
# component/ChatServer.ls? even though it's not a component.
class ChatServer
  (@io, @socket, @site, @user) ->

  connections: {} # XXX - may need to move this to redis
  chat-join: (c, cb) ~>
    console.warn \chat-join
    c.room = "#{@site.id}/conversations/#{c.id}"
    @connections[@socket.id] ||= {}
    @connections[@socket.id][c.id] = c
    @socket.join c.room
    cb null, c
  chat-leave: (c, cb) ~>
    console.warn \chat-leave
    delete @connections[@socket.id]?[c.id]
    @socket.leave c?room
    cb null, c
  chat-message: (message, cb) ~>
    ## if connection has a chat with message.chat_id use it
    if c = @connections[@socket.id]?[message.conversation_id]
      console.warn "remote chat already opened"
      err <~ db.conversation-add-message c.id, { user_id: message.from.id, body: message.text }
      return cb(err) if err
      message.id = m.id
      @io.sockets.in(c.room).emit \chat-message, message
      cb null, { conversation: c, message: m }

    ## else load it from the database
    else
      console.warn "need to setup new remote chat"
      err, c <~ db.conversation-find-or-create [{id:@user.id, name:@user.name}, {id:message.to.id, name:message.to.name}]
      if err then cb err

      # join the room for the conversation if we haven't already joined
      c.room = "#{@site.id}/conversations/#{c.id}"
      @connections[@socket.id] ||= {}
      @connections[@socket.id][c.id] = c
      @socket.join c.room

      # request a remote chat window be opened
      user-room = "#{@site.id}/users/#{message.to?id}"
      @io.sockets.in(user-room).emit \chat-open, c

      # broadcast message to channel after delay
      send-chat-message = ~>
        message.conversation_id = c.id
        err, m <~ db.conversation-add-message c.id, { user_id: message.from.id, body: message.text }
        return cb(err) if err
        message.id = m.id
        @io.sockets.in(c.room).emit \chat-message, message
        cb null, { conversation: c, message: m }
      set-timeout send-chat-message, 100ms

  chat-debug: (cb) ~>
    console.warn \chat-debug
    @socket.emit \debug, @connections

enter-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  @state[s].users[user.name] = u = { id: user.id, name: user.name }
  socket.join s
  socket.join "#s/users/#{user.id}"
  socket.in(s).broadcast.emit \enter-site, u

leave-site = (socket, site, user) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  delete @state[s].users[user.name]
  socket.leave s
  socket.leave "#s/users/#{user.id}"
  socket.in(s).broadcast.emit \leave-site, { id: user.id, name: user.name }

in-site = (socket, site) ~>
  s = site.id
  @state[s] ||= {}
  @state[s].users ||= {}
  users = keys @state[s].users
  users.for-each (name) ~>
    u = @state[s].users[name]
    socket.in(s).emit \enter-site, u # not braoadcast

user-from-session = (s, cb) ->
  unless s?passport?user
    return cb null, {id:0, name:\Anonymous, guest:true}
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
      if search-room
        socket.leave search-room

    socket.on \online-now, ->
      if site
        in-site socket, site

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

    #ChatServer
    chat-server = new ChatServer(io, socket, site, user)
    socket.on \chat-message, chat-server.chat-message
    socket.on \chat-join, chat-server.chat-join
    socket.on \chat-leave, chat-server.chat-leave
    socket.on \chat-debug, chat-server.chat-debug
