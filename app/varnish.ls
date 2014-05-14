require! {
  net
  async
}

# This is a pure node implementation of the wire protocol for the varnish admin port
# BUAHAHAHAHAHA
export read-varnish-responses = (buf) ->
  raw = buf.to-string!
  r = []
  while raw.length
    header = raw.match(/^(\d+) (\d+)\s*\n/)
    return r unless header
    m      = header.0
    code   = parse-int header.1
    length = parse-int header.2
    body   = raw.slice(m.length, length)
    c      = { code, length, body }
    r.push c
    raw := raw.slice(m.length + length + 1)
  r

# the docs on the varnish site say this is strictly a Request/Response protocol
# https://www.varnish-cache.org/trac/wiki/ManagementPort
export init = (cb = (->)) ->
  first-message-received = false
  cb-q = []
  cmd-q = async.queue ((cmd, cb) ->
    sock.write(cmd + "\n")
    console.log "[varnish command] #{cmd}"
    cb null
  ), 1

  var sock
  new-socket = ->
    sock := net.connect 2000
    sock.on \error, console.warn
    sock.on \close, ->
      console.info "[varnish] reconnecting"
      first-message-received := false
      set-timeout new-socket, 3000ms
    sock.on \data, (buf) ~>
      rs = read-varnish-responses(buf)
      for r in rs
        if first-message-received
          cb-q.shift! null, r.code, r.body  # call back with code of last request
        else
          # we want to skip the initial message
          # that varnish sends us
          first-message-received := true
  new-socket!

  # once housekeeping completed, export command
  export command = (cmd, cb = (->)) ->
    cb-q.push cb
    cmd-q.push cmd
    true

  cb null

# this gets overwritten after init is called
export command = -> throw new Error 'You must initialize varnish (call init!)'

# ban all
export ban-all = (cb = (->)) ->
  expr = "ban.url ."
  @command expr, cb

# ban single domain
export ban-domain = (domain, cb = (->)) ->
  expr = "ban req.http.host ~ #{domain}"
  @command expr, cb

# ban host/url pair
export ban = (b, cb = (->)) ->
  expr = "ban req.http.host ~ #{b.host} && req.url ~ #{b.url}"
  @command expr, cb
