require! {
  express
  http
  cors
  sh: \./server-helpers
}

# deny access to .ls files
!function deny-ls req, res, next
  if req.url.match /\.ls$/i
    # trying to match express response exactly so attacker doesn't know we are trying to hide .ls
    res.content-type \text
    res.send "Cannot GET #{req.url}", 404
  else
    next!

# cache 1 year in production, (cache will get blown on deploy due to changeset tagging)
global.DISABLE_HTTP_CACHE = !(process.env.NODE_ENV == 'production' or process.env.NODE_ENV == 'staging' or process.env.TEST_HTTP_CACHE)

const max-age = if DISABLE_HTTP_CACHE then 0 else (60 * 60 * 24) * 1 # 1 day max

module.exports =
  class CacheApp
    (@port) ->
    start: !(cb = (->)) ->
      process.title = "pb-cache-#{@port}"

      app = express!
        ..use deny-ls
        ..use cors(origin: '*', credentials: true)
        ..use express.static(\public, {max-age})
        # probe for haproxy
        ..get \/probe, (req, res) ->
          sh.caching-strategies.nocache res
          res.send 'OK'

      server = http.create-server app
        ..listen @port

      @stop = (cb) -> server.close(cb)

      cb!
