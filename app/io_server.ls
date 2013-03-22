require! {
  sio: 'socket.io'
  crc32: 'express/node_modules/buffer-crc32'
  cookie: 'express/node_modules/cookie'
  connect: 'express/node_modules/connect'
}

user-from-session = (s, cb) ->
  unless s?.passport?.user
    return cb 'invalid session', null
  [name, site_id] = s?.passport?.user?.split ':'
  #console.warn "deserialize", name, site_id
  (err, user) <- db.usr {name, site_id}
  cb err, user

@init = (server) ->
  io = sio.listen server
  io.set 'log level', 1

  io.set \authorization, (data, accept) ->
    if data.headers.cookie
      data.cookies = cookie.parse data.headers.cookie
      #console.log \cookie, data.cookies
      unsigned = connect.utils.parse-signed-cookie data.cookies['connect.sess'], cvars.secret
      #console.log \unsigned, unsigned

      if unsigned
        original-hash = crc32.signed unsigned
        session = connect.utils.parse-JSON-cookie(unsigned) || {}
        #console.log \session, session
        data.session = session
        return accept(null, true)
      else
        return accept("bad session?", false)
    else
      return accept("no cookie", false)

  io.on \connection, (socket) ->
    #console.warn 'connected'
    err, user <- user-from-session socket.handshake.session
    console.warn 'logged in as', user

