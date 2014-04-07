require! \net

# This is a pure node implementation of the wire protocol for the varnish admin port
# BUAHAHAHAHAHA
read-varnish-proto = (buf) ->
  raw = buf.to-string!
  if m = raw.match /^(\d{3}) (\d[\d ]{7})\n([\s\S]*)\n$/
    code = parse-int m[1]
    expected-len = parse-int(m[2])
    body = m[3]

    if body.length is expected-len
      [code, body]
    else
      throw new Error "Varnish Protocol Error (bad length: expected #{expected-len} but got #{body.length})"

  else
    throw new Error 'Varnish Protocol Error (bad format)'

# the docs on the varnish site say this is strictly a Request/Response protocol
# https://www.varnish-cache.org/trac/wiki/ManagementPort
export init = (cb = (->)) ->
  first-message-received = false
  cmd-q = []
  cb-q = []

  maybe-run-command = ->
    if cmd = cmd-q.shift!
      sock.write(cmd + "\n")
      console.log "[varnish command] #{cmd}"

  cmd-loop = ->
    #XXX:
    # 100ms loop is a workaround so node doesn't eat cpu
    # i need to figure out how to get this completely event-based if possible
    # what i am not clear on is whether or not we can asynchronously
    # send more than one command to varnish admin at a time before receiving
    # each individual response (i.e is it synchronous or async).. i am being
    # safe and assuming synchronous with a naively-non-scaleable algorithm here
    # for now but this long winded rant is so we can punt this for now and
    # figure it out later
    set-interval maybe-run-command, 100

  sock = net.connect 2000
  sock.on \error, console.warn
  sock.on \data, (buf) ~>
    [code, body] = read-varnish-proto(buf)
    if first-message-received
      cb-q.shift! null, code, body  # call back with code of last request
    else
      # we want to skip the initial message
      # that varnish sends us
      first-message-received := true
      cmd-loop! # start command loop

  # once housekeeping completed, export command
  export command = (cmd, cb = (->)) ->
    cmd-q.push cmd
    cb-q.push cb
    true

  cb!

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
