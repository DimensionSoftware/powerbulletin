(function(){
  var app, redir_to_www, html_50x, html_404, e, workers, reapWorkers, numWorkers, i, child, i$, ref$, len$, a, errHandler, this$ = this;
  require()({
    'os': 'os',
    'fs': 'fs',
    'async': 'async',
    'cluster': 'cluster',
    'express': 'express',
    'stylus': 'stylus',
    'fluidity': 'fluidity'
  });
  app = global.app = express();
  redir_to_www = express();
  html_50x = fs.readFileSync('public/50x.html').toString();
  html_404 = fs.readFileSync('public/404.html').toString();
  try {
    global.cvars = JSON.parse(fs.readFileSync('./config.json'));
  } catch (e$) {
    e = e$;
    console.log("Malformed configuration: " + e);
    return;
  }
  if (cluster.isMaster) {
    process.title = 'PowerBulletin [supervisor]';
    app.configure('production', function(){
      var id, e;
      fs.writeFileSync(cvars.tmp + "/tmp/powerbulletin.pid", process.pid);
      id = 'powerbulletin';
      try {
        process.setuid(id);
        return process.setgid(id);
      } catch (e$) {
        e = e$;
        return console.log("Unable to setuid/setgid " + id + ": " + e);
      }
    });
    workers = {};
    reapWorkers = function(){
      var pid, ref$, worker;
      for (pid in ref$ = workers) {
        worker = ref$[pid];
        process.kill(pid);
      }
      return process.exit();
    };
    process.on('SIGINT', reapWorkers);
    process.on('SIGTERM', reapWorkers);
    numWorkers = process.env.NODE_WORKERS || cvars.workers;
    for (i = 1; i <= numWorkers; ++i) {
      child = cluster.fork().process;
      workers[child.pid] = child;
      console.log("\n [1;37m.. ._________\nPowerBulletin [1;37;40m" + app.settings.env + "[0;m [1;37mon port [1;37;40m" + (process.env['NODE_PORT'] || 3000) + "[0;m [1;37mx " + numWorkers);
      console.log("[1;30;30m @ " + new Date() + "[0;m");
    }
    cluster.on('exit', function(worker){
      var newWorker;
      console.log("Worker " + worker.pid + " died");
      delete workers[worker.pid];
      newWorker = cluster.fork();
      return workers[newWorker.pid] = newWorker;
    });
  } else {
    process.title = "PowerBulletin [worker]";
    if (process.env.NODE_ENV === 'production') {
      process.on('uncaughtException', function(err){
        var timestamp;
        timestamp = new Date;
        console.warn('timestamp', timestamp);
        console.warn(err.message);
        return process.exit(1);
      });
      require('console-trace')({
        always: true,
        colors: false
      });
    } else {
      require('console-trace')({
        always: true,
        colors: true
      });
    }
    for (i$ = 0, len$ = (ref$ = [app]).length; i$ < len$; ++i$) {
      a = ref$[i$];
      a.set('view engine', 'jade');
      a.set('jsonp callback', true);
      a.use(express.cookieParser());
    }
    app.locals(cvars);
    app.use(function(err, req, res, next){
      if (err === 404) {
        return res.send(html_404(404));
      } else {
        return next(err);
      }
    });
    errHandler = function(responder){
      return function(err, req, res, next){
        var timestamp;
        responder(res);
        timestamp = new Date;
        console.warn(err.message);
        console.warn('timestamp', timestamp);
        console.warn('client_ip', req.headers['x-real-client-ip']);
        console.warn('user_agent', req.headers['user-agent']);
        console.warn('http_method', req.method);
        console.warn('url', req.headers.host + req.url);
        return process.exit(1);
      };
    };
    if (process.env.NODE_ENV === 'production') {
      app.error(errHandler(function(res){
        return res.send(html_50x, 500);
      }));
    }
    require()('./routes');
    redir_to_www.all('*', function(req, res){
      var protocol, host, uri, url;
      protocol = req.headers['x-forwarded-proto'] || 'http';
      host = 'powerbulletin.com';
      uri = req.url;
      url = "https://" + host + uri;
      return res.redirect(url, 301);
    });
    express().use(express.vhost('powerbulletin.com', redir_to_www)).use(express.vhost('www.powerbulletin.com', app)).use(express.vhost('m.powerbulletin.com', app)).listen(process.env['NODE_PORT'] || 3000);
  }
}).call(this);
