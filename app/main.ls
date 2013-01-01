
# dependencies
require! {
  \os
  \fs
  \async
  \cluster
  \express
}

app = express.create-server!

html_50x = fs.read-file-sync('public/50x.html').to-string!
html_404 = fs.read-file-sync('public/404.html').to-string!

# master
if cluster.is-master
  process.title = 'PowerBoard [supervisor]'
  app.configure \production, -> # write pidfile
    fs.write-file-sync '/tmp/weedmaps-node.pid', process.pid
    id = 'powerboard'
    try # ...and drop privileges
      process.setuid id
      process.setgid id
    catch e
      console.log "Unable to setuid/setgid #{id}: #{e}"

  workers = { }
  reap-workers = ->
    for pid,worker of workers
      process.kill pid
    process.exit!
  process.on 'SIGINT',  reap-workers
  process.on 'SIGTERM', reap-workers

  num-workers = process.env.WM_NODE_WORKERS or num-cpus
  for i in [1..num-workers]
    child = cluster.fork!process
    workers[child.pid] = child
    console.log "\n Booted [1;37;40m#{app.settings.env}[0;m on port [1;37;40m#{process.env['NODE_PORT'] || 3000}[0;m"
    console.log "  `"
    console.log "   o  Since", new Date()

  cluster.on \exit, (worker) ->
    console.log "Worker #{worker.pid} died"
    delete workers[worker.pid]
    new-worker = cluster.fork()
    workers[new-worker.pid] = new-worker

  app.configure 'development', () ->
    restarting = false
    restart = (event, filename) ->
      if filename
        if filename.match(/\.(coffee|ls)$/) and not restarting
          console.log "#{filename} changed -- restarting"
          restarting = true
          process.kill process.pid
      else
        console.log "#{event} on unknown file"
    fs.watch '.', {}, restart
    fs.watch 'lib', {}, restart
    fs.watch 'handlers', {}, restart

# worker
else
  process.title = "PowerBoard [worker]"

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

  wm-cvars.get_cvars app.settings.env, (cvars) ->
    global.cvars = cvars
    mw = wm-middleware.init_with(cvars)

    for a in [app]
      a.use(mw.ip_lookup)
      a.use(mw.rate_limit)
      a.set('view engine', 'ejs')
      a.register('.eco', eco)
      a.set('view options', open: '{%', close: '%}', pretty:false )
      a.set('jsonp callback', true)
      a.use(wm-middleware.trycatch)
      a.use(express.cookieParser())
      #a.use(express_useragent.express())
      a.use(express_validator)
      a.helpers(wm-helpers)

    # common vars!
    # app
    app.locals(cvars)
    app.locals(sh_common: sh_common, sh_hours: sh_hours)

    err_handler = (responder) =>
      (err, req, res, next) =>
        responder(res)

        timestamp = new Date
        console.warn err.message
        console.warn 'timestamp'   , timestamp
        console.warn 'client_ip'   , req.headers['x-real-client-ip']
        console.warn 'user_agent'  , req.headers['user-agent']
        console.warn 'http_method' , req.method
        console.warn 'url'         , req.headers.host + req.url
        process.exit 1

    # 404 handler, if not 404, punt
    app.error (err, req, res, next) =>
      if err is 404
        res.send html_404 404
      else
        next err

    # give us some context in error_log when exceptions happen
    if process.env.NODE_ENV == 'production'
      app.error err_handler((res) -> res.send(html_50x, 500))

    # routes
    # app
    wm-routes.apply_routes_to(app, cvars)

    redir_to_www.all '*', (req, res) ->
      protocol = req.headers['x-forwarded-proto'] or 'http'
      host     = 'powerboard.com'
      uri      = req.url
      url      = "https://#{host}#{uri}"
      res.redirect url, 301

    express.create-server!
      .use(express.vhost 'powerboard.com', redir_to_www)
      .use(express.vhost 'www.powerboard.com', app)
      .use(express.vhost 'm.powerboard.com', app)
      .listen process.env['NODE_PORT'] || 3000

