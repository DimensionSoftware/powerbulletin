require! \net

# This is a pure node implementation of the wire protocol for the varnish admin port
# BUAHAHAHAHAHA
# you can use it like so:
# v.command 'ban.url .', cl
# right now it assumes that varnish is on localhost
read-varnish-proto = (buf) ->
  raw = buf.to-string!
  if m = raw.match /^(\d{3}) (\d[\d ]{7})\n([\s\S]*)$/
    code = parse-int m[1]
    expected-len = parse-int(m[2]) + 1
    body = m[3]

    if body.length is expected-len
      code
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

  cmd-loop = ->
    set-interval maybe-run-command, 10

  sock = net.connect 2000
  sock.on \error, console.warn
  sock.on \data, (buf) ~>
    code = read-varnish-proto(buf)
    if first-message-received
      cb-q.shift! null, code  # call back with code of last request
    else
      # we want to skip the initial message
      # that varnish sends us
      first-message-received := true
      cmd-loop! # start command loop

  # once housekeeping completed, export command
  export command = (cmd, cb) ->
    cmd-q.push cmd
    cb-q.push cb
    true

  cb!

