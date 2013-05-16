
# this file is compiled to js so this is so we can load .ls files
# it is compiled to js to work around a bug in cluster where child processes
# receive incorrect arguments (in particular with --prof when passed with lsc's -n flag)
require \LiveScript

# dependencies
require! {
  os
  fs
  async
  cluster
  express
  http
  \express-resource
  stylus
  fluidity
  \./io-server
  \./elastic
  \express/node_modules/connect
  pg: \./postgres
  v: \./varnish
}
global <<< require \prelude-ls

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

require! shelljs

{code, output} = shelljs.exec('git rev-parse HEAD', silent: true)
global.CHANGESET = output.trim!

global.DISABLE_HTTP_CACHE = !(process.env.NODE_ENV == 'production' or process.env.NODE_ENV == 'staging' or process.env.TEST_HTTP_CACHE)

proc = process

proc.on 'uncaughtException', (e) -> throw e

# XXX instead of rallying the troops, encapsulate for quicker & more resilient teardown/startup:
#   - new System(config, db, express-apps...) # worker
app = global.app = express!
cache-app        = express!

server = null

graceful-shutdown = ->
  console.warn 'Graceful shutdown started'
  set-timeout (-> console.warn("Forcing shutdown"); process.exit!), 5000
  server.close (err) ->
    console.warn 'Graceful shutdown finished'
    console.warn err if err
    process.exit!

html_50x = fs.read-file-sync('public/50x.html').to-string!
html_404 = fs.read-file-sync('public/404.html').to-string!

try # load config.json
  global.cvars = require '../config/common'
  global.cvars <<< require "../config/#{proc.env.NODE_ENV or \development}"

  try
    global.cvars <<< require '../config/local' # local settings which aren't in version control
  catch
    # do nothing

  cvars.env                = proc.env.NODE_ENV
  cvars.process-start-date = new Date!
catch e
  console.log "Inspect config.json: #{e}"
  return

require! mw: './middleware'

#{{{ Master
num-workers = proc.env.NODE_WORKERS or cvars.workers
if cluster.is-master
  console.log "\n [1;37m.. ._________\nPowerBulletin [1;37;40m#{app.settings.env}[0;m [1;37mon port [1;37;40m#{proc.env['NODE_PORT'] || cvars.port}[0;m [1;37mx #{num-workers}"
  console.log "[1;30;30m @ #{new Date()}[0;m"
  proc.title = 'pb-supervisor'
  app.configure \production, -> # write pidfile
    fs.write-file-sync "#{cvars.tmp}/pb.pid", proc.pid
    id = \pb
    try # ...and drop privileges
      proc.setuid id
      #proc.setgid id
    catch e
      console.log "Unable to setuid/setgid #{id}: #{e}"

  workers = {}
  reap-workers = ->
    for pid,worker of workers
      proc.kill pid
    proc.exit!
  proc.on 'SIGINT',  reap-workers
  proc.on 'SIGTERM', reap-workers

  for i from 1 to num-workers
    child = cluster.fork!process
    workers[child.pid] = child

  cluster.on \exit, (worker) ->
    console.log "Worker #{worker.pid} died"
    delete workers[worker.pid]
    new-worker = cluster.fork!
    workers[new-worker.pid] = new-worker
#}}}
#{{{ Worker
else
  proc.title = "pb-worker"
  console.log "[1;30;30m  `+ worker #{proc.pid}[0;m"
  # XXX/FIXME: would like to actually block until initialized, except voltdb never calls back...
  # then we can use back-calls before initializing the worker....
  err <- pg.init
  if err then throw err
  global.db = pg.procs

  err <- v.init
  if err then throw err
  v.ban-all! # start cache clean on startup

  err <- elastic.init
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
  require! \./pb-routes

  # 404 handler, if not 404, punt
  app.use (err, req, res, next) ~>
    if err is 404
      res.send html_404, 404
    else
      explain = err-handler (res) -> res.send html_50x, 500
      explain err, req, res, next

  # all domain-based catch-alls & redirects, # cache 1 year in production, (cache will get blown on deploy due to changeset tagging)
  max-age = if DISABLE_HTTP_CACHE then 0 else (60 * 60 * 24 * 365) * 1000
  cache-app.use(express.static \public {max-age})

  sock = express!

  # bind shared cache domains
  for i in ['', 2, 3, 4, 5]
    #XXX: this is a hack but hey we are always using protocol-less urls so should never break :)
    #  removing leading //
    sock.use(express.vhost cvars["cache#{i}Url"].slice(2), cache-app)

  # dynamic app can automatically check req.host
  sock.use(app)

  # need this for socket.io
  server := http.create-server sock
  io-server.init server

  server.listen proc.env['NODE_PORT'] || cvars.port
  #sock.listen   proc.env['NODE_PORT'] || cvars.port
#}}}
# vim:fdm=marker
