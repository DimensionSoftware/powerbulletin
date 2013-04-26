require! {
  async
  elastic: './elastic'
  RedisStore: 'socket.io/lib/stores/redis'
  redis: 'socket.io/node_modules/redis'
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

new-poller = (q) ->
  poller = {q}

  work = ->
    console.log 'poller doing work', JSON.stringify(poller)

  poller.interval-id = set-interval work, 2000

  return poller

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

  @io = init-io(unique-port).sockets
  @sock = init-ioc unique-port

  @sock.on 'register-query' (q) ->
    if poller = pollers[q]
      # poller exists
      console.warn 'poller exists', JSON.stringify(poller)
    else
      # create new poller
      pollers[q] = new-poller q
      console.warn 'poller created', JSON.stringify(pollers[q])

  @io.emit \debug, 'search-notifier-up'

  # TODO:
  # * need to start a setInterval loop which periodically will
  #   use clearInterval on any pollers which are no longer needed if
  #   and only if the channel is empty (no subscribers)
  # * pollers need to do REAL work and push elastic results down the channel

  cb!

