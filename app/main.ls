
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
  mw: './middleware'
}

app = global.app = express!
redir_to_www = express!

html_50x = fs.read-file-sync('public/50x.html').to-string!
html_404 = fs.read-file-sync('public/404.html').to-string!

try # load config.json
  global.cvars = JSON.parse(fs.read-file-sync './config.json')
catch e
  console.log "Inspect config.json: #{e}"
  return

# master
num-workers = process.env.NODE_WORKERS or cvars.workers
if cluster.is-master
  console.log "\n [1;37m.. ._________\nPowerBulletin [1;37;40m#{app.settings.env}[0;m [1;37mon port [1;37;40m#{process.env['NODE_PORT'] || cvars.port}[0;m [1;37mx #{num-workers}"
  console.log "[1;30;30m @ #{new Date()}[0;m"
  process.title = 'PowerBulletin [supervisor]'
  app.configure \production, -> # write pidfile
    fs.write-file-sync "#{cvars.tmp}/tmp/powerbulletin.pid", process.pid
    id = \powerbulletin
    try # ...and drop privileges
      process.setuid id
      process.setgid id
    catch e
      console.log "Unable to setuid/setgid #{id}: #{e}"

  workers = {}
  reap-workers = ->
    for pid,worker of workers
      process.kill pid
    process.exit!
  process.on 'SIGINT',  reap-workers
  process.on 'SIGTERM', reap-workers

  for i from 1 to num-workers
    child = cluster.fork!process
    workers[child.pid] = child

  cluster.on \exit, (worker) ->
    console.log "Worker #{worker.pid} died"
    delete workers[worker.pid]
    new-worker = cluster.fork()
    workers[new-worker.pid] = new-worker

# worker
else
  process.title = "PowerBulletin [worker]"
  console.log "[1;30;30m  `+ worker #{process.pid}[0;m"

  if process.env.NODE_ENV == 'production'
    process.on 'uncaughtException', (err) ->
      timestamp = new Date
      console.warn 'timestamp', timestamp
      console.warn err.message
      process.exit 1

    require('console-trace')({
      always: true
      colors: false
    })
  else
    require('console-trace')({
      always: true
      colors: true
    })

  for a in [app]
    a.use(mw.ip-lookup)
    a.use(mw.rate-limit)
    a.use(express.cookieParser())
    a.set('view engine', 'jade')
    a.set('jsonp callback', true)

  # common vars!
  # app
  app.locals(cvars)

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
      process.exit 1
  if process.env.NODE_ENV == 'production'
    app.error err-handler((res) -> res.send(html_50x, 500))

  # routes
  require! './routes'

  # all domain-based catch-alls & redirects
  redir_to_www.all '*', (req, res) ->
    protocol = req.headers['x-forwarded-proto'] or 'http'
    host     = req.host
    uri      = req.url
    url      = "https://#{host}#{uri}"
    res.redirect url, 301

  sock = express!
  for domain in ['localhost', cvars.host] # TODO bind all domains -- should come from voltdb
    sock
      .use(express.vhost "m.#{domain}", redir_to_www)
      .use(express.vhost domain, redir_to_www)
      .use(express.vhost "www.#{domain}", app)
  sock.listen process.env['NODE_PORT'] || cvars.port
