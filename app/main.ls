
# dependencies
require! {
  \os
  \fs
  \async
  \cluster
  \express
  \express-resource
  \stylus
  \fluidity
}
global <<< require \prelude-ls

proc = process

app = global.app = express!
redir-to-www     = express!
cache-app        = express!

html_50x = fs.read-file-sync('public/50x.html').to-string!
html_404 = fs.read-file-sync('public/404.html').to-string!

try # load config.json
  global.cvars = JSON.parse(fs.read-file-sync './config.json')
  cvars.process-start-date = new Date!
  for i in ['', 2, 3, 4, 5] # add cache domains
    cvars["cache#{i}_url"] = "//#{cvars.cache_prefix}#{i}.#{cvars.host}"
catch e
  console.log "Inspect config.json: #{e}"
  return

require! mw: './middleware'

#{{{ Master
num-workers = proc.env.NODE_WORKERS or cvars.workers
if cluster.is-master
  console.log "\n [1;37m.. ._________\nPowerBulletin [1;37;40m#{app.settings.env}[0;m [1;37mon port [1;37;40m#{proc.env['NODE_PORT'] || cvars.port}[0;m [1;37mx #{num-workers}"
  console.log "[1;30;30m @ #{new Date()}[0;m"
  proc.title = 'PowerBulletin [supervisor]'
  app.configure \production, -> # write pidfile
    fs.write-file-sync "#{cvars.tmp}/powerbulletin.pid", proc.pid
    id = \powerbulletin
    try # ...and drop privileges
      proc.setuid id
      proc.setgid id
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
  proc.title = "PowerBulletin [worker]"
  console.log "[1;30;30m  `+ worker #{proc.pid}[0;m"

  if proc.env.NODE_ENV == 'production'
    proc.on 'uncaughtException', (err) ->
      timestamp = new Date
      console.warn 'timestamp', timestamp
      console.warn err.message
      proc.exit 1

    require('console-trace')({
      always: true
      colors: false
    })
  else
    require('console-trace')({
      always: true
      colors: true
    })

  for a in [app] # apply app defaults
    a.use mw.multi-domain
    a.use mw.ip-lookup
    a.use mw.rate-limit
    a.use express.cookieParser!
    a.set 'view engine' 'jade'
    a.set 'views' 'app/views'
    a.enable 'json callback'
    a.enable 'trust proxy' # parse x-forwarded-for in req.ip, etc...

  # common locals
  app.locals cvars

  # 404 handler, if not 404, punt
  app.use (err, req, res, next) ~>
    if err is 404
      res.send html_404 404
    else
      next err

  # give us some context in error_log when exceptions happen
  err-handler = (responder) ~>
    (err, req, res, next) ~>
      responder res
      timestamp = new Date
      console.warn err.message
      console.warn 'timestamp'   , timestamp
      console.warn 'client_ip'   , req.headers['x-real-client-ip']
      console.warn 'user_agent'  , req.headers['user-agent']
      console.warn 'http_method' , req.method
      console.warn 'url'         , req.headers.host + req.url
      proc.exit 1
  if proc.env.NODE_ENV == 'production'
    app.error err-handler((res) -> res.send(html_50x, 500))

  # routes
  require! './routes'

  # all domain-based catch-alls & redirects
  cache-app.use(express.static \public max-age:7200 * 1000)

  redir-to-www.all '*', (req, res) ->
    protocol = req.headers['x-forwarded-proto'] or 'http'
    host     = req.host
    uri      = req.url
    url      = "https://#{host}#{uri}"
    res.redirect url, 301

  sock = express!
  for domain in ['pbstage.com', 'pb.com', cvars.host] # TODO bind all domains -- should come from voltdb
    sock
      .use(express.vhost "m.#{domain}", redir-to-www)
      .use(express.vhost domain, redir-to-www)
      .use(express.vhost "www.#{domain}", app)
    for i in ['', 2, 3, 4, 5] # add cache domains
      sock.use(express.vhost "#{cvars.cache_prefix}#{i}.#{domain}", cache-app)
  sock.listen proc.env['NODE_PORT'] || cvars.port
#}i}}
# vim:fdm=marker
