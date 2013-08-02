require! {
  async
  redis
  elastic: './elastic'
  RedisStore: 'socket.io/lib/stores/redis'
  s: \./search
  sio: 'socket.io'
  sioc: 'socket.io-client'
}

init-io = (port) ->
  redis-opts =
    redis: redis
    redis-pub: redis.create-client!
    redis-sub: redis.create-client!
    redis-client: redis.create-client!

  redis-store = new RedisStore(redis-opts)

  io = sio.listen port # ideally don't need to even listen on port but oh well
  io.set 'log level', 1
  io.set \store, redis-store

  return io

init-ioc = (port) ->
  # i know this is hacky but is there an easier way to internally connect to socket.io?? ; )
  # we could have a dedicated broker but i feel like that is less partitionable
  # -- melderz
  ioc = sioc.connect "http://127.0.0.1:#{port}"

  # standard debugging nonsense ;)
  ioc.on \debug (data) ->
    console.log \debug, data

  return ioc

# poller has these properties:
# * room (name of socket.io room to emit results to)
# * searchopts (including q (querystring))
# * site-id (site-id to query)
new-poller = (io, elc, poller) ->
  # randomize work interval so we make better use of event architecture
  # but only but a small amount
  work-interval = 3000 + (Math.floor (Math.random! * 500)) # in ms

  # step into my time machine, darling, this will require duplicate detection on client...
  now = new Date - 10000

  cutoff = new Date(now - work-interval)
  busy = false

  work = ->
    if busy # just in case work-interval is exceeded
      console.warn "! work-interval of #{work-interval}ms was exceeded for #{poller.room}"
      console.warn "! (waiting till next interval...)"
    else
      busy := true

      ch = io.sockets.in(poller.room)
      #console.log "work tick for room #{poller.room}"
      now = new Date
      popts = ({} <<< poller.searchopts) <<< {stream: {cutoff, now}}
      console.log JSON.stringify({popts})
      err, res <- s.search popts
      if err then throw err
      cutoff := now
      # XXX: replace this emit with a ch.emit \new-post
      for hit in res.hits
        ch.emit \new-hit, hit

      busy := false

  interval-id = set-interval work, work-interval

  poller.stop = ->
    clear-interval interval-id
    console.warn "|=| stopped poller: #{poller.room}"

  return poller

debug-info = (io, pollers) ->
  rooms = {[room, clients.length] for room, clients of io.sockets.manager.rooms}
  #console.log '--DEBUG: ROOMS'
  #console.log rooms
  #console.log '--DEBUG: POLLERS'
  #console.log Object.keys(pollers)

stop-inactive-pollers = (io, pollers) ->
  rooms = io.sockets.manager.rooms
  to-delete = []
  for pname, poller of pollers
    # stop poller unless there is a room for it
    unless rooms['/' + pname]
      poller.stop!
      to-delete.push pname

  # delete after to avoid weird condition where poller isn't cleaned up
  for pname in to-delete
    delete pollers[pname]

# port must be unique on given host and should be protected!!!
# XXX: its sort of a hack i would love to just not listen on a tcp
# socket and listen and receive events purely via redis but I don't
# know how at the moment, announce can only emit events, not receive them
export init = (unique-port = 9999, cb = (->)) ->
  process.title = \pb-search
  pollers = {}

  err <~ elastic.init
  if err then return cb err
  elc = elastic.client

  # start socket.io server on unique-port
  io = init-io(unique-port)

  # create io-client (to receive events)
  sock = init-ioc unique-port

  sock.on 'register-search' (opts) ~>
    if poller = pollers[opts.room]
      # poller exists
      console.warn 'poller exists', JSON.stringify(poller)
    else
      # create new poller
      poller = new-poller io, elc, opts

      pollers[opts.room] = poller
      console.warn 'poller created', JSON.stringify(poller)

  io.sockets.emit \debug, 'search-notifier-up'

  set-interval (-> debug-info(io, pollers)), 10000
  set-interval (-> stop-inactive-pollers(io, pollers)), 15000

  cb!
