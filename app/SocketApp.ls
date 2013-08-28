require! {
  express
  http
  \./io-server
  sh: \./server-helpers
}

module.exports =
  class SocketApp
    (@port) ->
    start: !(cb = (->)) ->
      process.title = "pb-rt-#{@port}"

      app = express!
        # probe for haproxy
        ..get \/probe, (req, res) ->
          sh.caching-strategies.nocache res
          res.send 'OK'

      server = http.create-server app
      io-server.init server
      server.listen @port

      @stop = (cb) -> server.close(cb)

      cb!
