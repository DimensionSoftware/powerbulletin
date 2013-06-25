function get-CHANGESET
  {code, output} = shelljs.exec('git rev-parse HEAD', silent: true)
  output.trim!

# XXX: ugh ?
# I hate messing with global state, can we remove this? : )
global <<< require \prelude-ls

# this file is compiled to js so this is so we can load .ls files
# it is compiled to js to work around a bug in cluster where child processes
# receive incorrect arguments (in particular with --prof when passed with lsc's -n flag)
require \LiveScript
require \./load-cvars

# dependencies
require! {
  os
  fs
  async
  express
  http
  \express-resource
  \express-validator
  stylus
  fluidity
  \./auth
  \./io-server
  \./elastic
  \express/node_modules/connect
  pg: \./postgres
  v: \./varnish
  m: \./pb-models
  \./sales-app
  shelljs
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
global.CHANGESET = get-CHANGESET!

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

      proc.on \uncaughtException, (e) -> throw e

      app = global.app = express!

      cache-app        = express!

      server = null

      graceful-shutdown = !(cb = (->)) ->
        console.warn 'Graceful shutdown started'
        sd-timeout = set-timeout (-> console.warn("Server never closed, restarting anyways"); cb!), 5000ms
        try
          server.close (err) ->
            clear-timeout sd-timeout
            console.warn 'Graceful shutdown finished'
            console.warn err if err
            cb!
        catch
          cb!

      html_50x = fs.read-file-sync('public/50x.html').to-string!
      html_404 = fs.read-file-sync('public/404.html').to-string!

      console.log "\n [1;37m.. ._________\nPowerBulletin [1;37;40m#{app.settings.env}[0;m [1;37mon port [1;37;40m#{@port}"

      app.configure \production, -> # write pidfile
        fs.write-file-sync "#{cvars.tmp}/pb.pid", proc.pid
        id = \pb
        try # ...and drop privileges
          proc.setuid id
          #proc.setgid id
        catch e
          console.log "Unable to setuid/setgid #{id}: #{e}"

      proc.title = "pb-worker-#{@port}"
      console.log "[1;30;30m  `+ worker #{proc.pid}[0;m"

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
        proc.on 'uncaughtException', (err) ->
          timestamp = new Date
          console.warn 'timestamp', timestamp
          console.warn err.message
          console.warn 'uncaught exception in worker, shutting down'
          graceful-shutdown!

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

      app.use connect.logger(immediate: false, format: \dev) if (app.env is \development or app.env is void)

      for a in [app] # apply app defaults
        a.use mw.vars
        a.use mw.cvars
        a.use mw.multi-domain
        a.use mw.ip-lookup
        a.use mw.rate-limit
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
          graceful-shutdown!

      # routes
      #
      # XXX: this is hacky, pb-routes should be turned into its own app that can be app.use(d)
      # right now it depends on global.app being available, hence the ordering
      require! \./pb-routes

      # 404 handler, if not 404, punt
      err-or-notfound = (err, req, res, next) ~>
        if err is 404
          res.send html_404, 404
        else
          explain = err-handler (res) -> res.send html_50x, 500
          explain err, req, res, next

      app.use err-or-notfound
      sales-app.use err-or-notfound

      require! \./auth-handlers
      sales-mw =
        * mw.vars
        * mw.cvars
        * mw.multi-domain
      sales-mw.for-each (-> sales-app.use it)
      sales-app.enable 'json callback'
      sales-app.enable 'trust proxy' # parse x-forwarded-for in req.ip, etc...
      sales-personal-mw =
        * express-validator
        * express.body-parser!
        * express.cookie-parser!
        * express.cookie-session {secret:cvars.secret}
        * auth.mw.initialize
        * auth.mw.session
      auth-handlers.apply-to sales-app, sales-mw ++ sales-personal-mw # XXX - The ++ shouldn't be necessary, but I can't seem to get it to work otherwise.

      # all domain-based catch-alls & redirects, # cache 1 year in production, (cache will get blown on deploy due to changeset tagging)
      max-age = if DISABLE_HTTP_CACHE then 0 else (60 * 60 * 24 * 365) * 1000
      cache-app.use(express.static \public {max-age})

      sock = express!

      # bind shared cache domains
      for i in ['', 2, 3, 4, 5]
        #XXX: this is a hack but hey we are always using protocol-less urls so should never break :)
        #  removing leading //
        sock.use(express.vhost cvars["cache#{i}Url"].slice(2), cache-app)

      sock.use(express.vhost 'pb.com', sales-app)

      # dynamic app can automatically check req.host
      sock.use(app)

      # need this for socket.io
      server := http.create-server sock
      io-server.init server

      console.log {@port}
      server.listen @port

      @stop = graceful-shutdown
      cb!

# vim:fdm=marker
