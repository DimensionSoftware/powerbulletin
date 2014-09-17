require!  shelljs

function get-CHANGESET
  {code, output} = shelljs.exec('git rev-parse HEAD', silent: true)
  output.trim!

# do this as early as possible so it exists for js-urls and css-urls
global.CHANGESET = get-CHANGESET!

global <<< require \prelude-ls

# this file is compiled to js so this is so we can load .ls files
# it is compiled to js to work around a bug in cluster where child processes
# receive incorrect arguments (in particular with --prof when passed with lsc's -n flag)
require \./load-cvars

# dependencies
require! {
  os
  fs
  async
  express
  http
  cors
  \express-resource
  \express-validator
  stylus
  fluidity
  \./auth
  \./elastic
  sh: \./server-helpers
  \express/node_modules/connect
  pg: \./postgres
  v: \./varnish
  m: \./pb-models
  \./sales-app
  _: \lodash
}

# {{{ Caching strategy notes (pages expire quickly; assets forever)
# not-so-well worded rant, just wanted to get thoughts down though...
#
# using current CHANGESET as a cache prefix, this way all upstream cdn proxies
# will be forced to blow their cache as well (this works on varnish too)
# we can't use this technique for 'pretty url' pages
# for instance homepage will always be '/' so we have to set a short ttl on that
# inevitably or any other content html pages
#
# perhaps we can set a 1 minute caching for homepage as I had suggested before
# if we want more freshness than 1 minute resolution, lets use client javascript to
# 'catch the dom up'
#
# so basically we end up with pages which we can use the CHANGESET as a cache prefix for like css,js etc
# we can set a super duper long ttl like a million years or whatever because the
# cache will be blown on each deploy with this changeset as part of the cache key
# and pages we shouldn't set long ttls on like html content pages that change and
# we will not use the changeset as part of the cache key for...
# }}}

global.DISABLE_HTTP_CACHE = !(process.env.NODE_ENV == 'production' or process.env.NODE_ENV == 'staging' or process.env.TEST_HTTP_CACHE)

max-age = if DISABLE_HTTP_CACHE then 0 else (60 * 60 * 24 * 365) * 1000

require \./load-cvars

require! mw: './middleware'

module.exports =
  class ServerApp
    (@port) ->
    start: !(cb = (->)) ->
      # XXX: I know this is a messy port, but we had a lot going on
      # and I had to encapsulate this all
      #
      # TODO: split into neater functions

      proc = process

      proc.on \uncaughtException, (err) ->
        timestamp = new Date
        console.warn 'timestamp', timestamp
        console.warn err.message
        console.warn err.stack
        console.warn 'uncaught exception in worker, shutting down'
        graceful-shutdown!

      app = express!

      server = null

      _graceful-shutdown = !(cb = (->)) ->
        console.warn 'Graceful shutdown started'
        hup-or-die = ->
          if process.env.NODE_ENV is \production
            process.exit!
          else
            process.kill process.pid, \SIGHUP # XXX be sure to reload (if cb is default)
            cb!

        restart = set-timeout (-> console.warn("Server never closed, restarting anyways"); hup-or-die!), 1000ms
        try
          server.close (err) ->
            clear-timeout restart
            console.warn 'Graceful shutdown finished'
            console.warn err if err
            hup-or-die!
        #catch # XXX shouldn't need to catch (duplicates call to hup-or-die)
        #  hup-or-die!
      graceful-shutdown = _.debounce _graceful-shutdown, 500ms, true

      html_50x = fs.read-file-sync('public/50x.html').to-string!
      html_404 = fs.read-file-sync('public/404.html').to-string!

      console.log "\n [1;37m.. ._________\nPowerBulletin [1;37;40m#{app.settings.env}[0;m [1;37mon port [1;37;40m#{@port}"

      if process.env.NODE_ENV is \production
        fs.write-file-sync "#{cvars.tmp}/pb.pid", proc.pid
        id = \pb
        try # ...and drop privileges
          proc.setgid id
          proc.setuid id
        catch e
          console.log "Unable to setuid/setgid #{id}: #{e}"

      proc.title = "pb-worker-#{@port}"
      console.log "[1;30;30m  `+ worker #{proc.pid}[0;m"
      console.log "[1;30;30m  `+ Testing HTTP Cache!!![0;m" if process.env.TEST_HTTP_CACHE

      err <~ pg.init
      if err then throw err
      global.db = pg.procs

      # initialize models
      err <~ m.init
      if err then throw err

      # mixing additional keys into 'db' namespace
      do -> pg.procs <<< { [k,v] for k,v of m when k not in <[orm client driver]> }

      err <~ v.init
      if err then throw err
      v.ban-all! # start cache clean on startup

      err <~ elastic.init
      if err then throw err
      global.elc = elastic.client

      if proc.env.NODE_ENV == 'production'
        proc.on 'SIGTERM', ->
          console.warn 'SIGTERM received by worker, shutting down'
          graceful-shutdown!

        require('console-trace')({
          always: true
          colors: false
        })
      else
        require('console-trace')({
          always: true
          colors: true
        })

      #log-format = ":method :req[Host]:url :status :response-time - :res[Content-Length]"

      if (env is \development or env is void)
        app.use connect.logger(immediate: false, format: sh.dev-log-format)
      else
        app.use connect.logger(immediate: false, format: sh.prod-log-format)

      for a in [app] # apply app defaults
        a.use mw.vars
        a.use mw.cvars
        a.use mw.multi-domain
        a.use mw.ip-lookup
        a.use mw.rate-limit
        a.use express-validator
        a.set 'view engine' \jade
        a.set \views \app/views
        a.enable 'json callback'
        a.enable 'trust proxy' # parse x-forwarded-for in req.ip, etc...

      # give us some context in error_log when exceptions happen
      err-handler = (responder) ~>
        (err, req, res, next) ~>
          timestamp = new Date
          console.error """

          timestamp    : #timestamp
          client_ip    : #{req.headers['x-real-client-ip']}
          user_agent   : #{req.headers['user-agent']}
          http_method  : #{req.method}
          url          : #{req.headers.host + req.url}
          user         : #{req.user?name}

          #{err.stack}
          """
          responder res
          #graceful-shutdown!

      # bind all routes
      pbr = require \./pb-routes
      pbr.use app

      # 404 handler, if not 404, punt
      err-or-notfound = (err, req, res, next) ~>
        if err is 404
          res.send 404, html_404
        else
          explain = err-handler (res) -> res.send 500, html_50x
          explain err, req, res, next

      app.use err-or-notfound
      sales-app.use err-or-notfound

      sock = express!

      # setup probe for varnish load balancer, really simple, doesn't need any middleware
      # and this also avoids logging in dev mode :D
      sock.get '/probe', (req, res) ->
        sh.caching-strategies.nocache res
        res.send 'OK'

      sock.use(express.vhost (if process.env.NODE_ENV is \production then \powerbulletin.com else \pb.com), sales-app)

      # dynamic app can automatically check req.host
      sock.use(app)

      # need this for socket.io
      server := http.create-server sock

      console.log {@port}
      server.listen @port

      @stop = graceful-shutdown
      cb!

# vim:fdm=marker
