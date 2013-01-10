(function(){
  var proc, app, redirToWww, cacheApp, html_50x, html_404, i$, ref$, len$, i, e, numWorkers, workers, reapWorkers, child, a, errHandler, sock, domain, j$, ref1$, len1$, this$ = this;
  require()({
    'os': 'os',
    'fs': 'fs',
    'async': 'async',
    'cluster': 'cluster',
    'express': 'express',
    'express-resource': 'express-resource',
    'stylus': 'stylus',
    'fluidity': 'fluidity'
  });
  import$(global, require('prelude-ls'));
  proc = process;
  app = global.app = express();
  redirToWww = express();
  cacheApp = express();
  html_50x = fs.readFileSync('public/50x.html').toString();
  html_404 = fs.readFileSync('public/404.html').toString();
  try {
    global.cvars = JSON.parse(fs.readFileSync('./config.json'));
    cvars.processStartDate = new Date();
    for (i$ = 0, len$ = (ref$ = ['', 2, 3, 4, 5]).length; i$ < len$; ++i$) {
      i = ref$[i$];
      cvars["cache" + i + "_url"] = "//" + cvars.cache_prefix + i + "." + cvars.host;
    }
  } catch (e$) {
    e = e$;
    console.log("Inspect config.json: " + e);
    return;
  }
  require()({
    mw: './middleware'
  });
  numWorkers = proc.env.NODE_WORKERS || cvars.workers;
  if (cluster.isMaster) {
    console.log("\n [1;37m.. ._________\nPowerBulletin [1;37;40m" + app.settings.env + "[0;m [1;37mon port [1;37;40m" + (proc.env['NODE_PORT'] || cvars.port) + "[0;m [1;37mx " + numWorkers);
    console.log("[1;30;30m @ " + new Date() + "[0;m");
    proc.title = 'PowerBulletin [supervisor]';
    app.configure('production', function(){
      var id, e;
      fs.writeFileSync(cvars.tmp + "/powerbulletin.pid", proc.pid);
      id = 'powerbulletin';
      try {
        proc.setuid(id);
        return proc.setgid(id);
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
        proc.kill(pid);
      }
      return proc.exit();
    };
    proc.on('SIGINT', reapWorkers);
    proc.on('SIGTERM', reapWorkers);
    for (i = 1; i <= numWorkers; ++i) {
      child = cluster.fork().process;
      workers[child.pid] = child;
    }
    cluster.on('exit', function(worker){
      var newWorker;
      console.log("Worker " + worker.pid + " died");
      delete workers[worker.pid];
      newWorker = cluster.fork();
      return workers[newWorker.pid] = newWorker;
    });
  } else {
    proc.title = "PowerBulletin [worker]";
    console.log("[1;30;30m  `+ worker " + proc.pid + "[0;m");
    if (proc.env.NODE_ENV === 'production') {
      proc.on('uncaughtException', function(err){
        var timestamp;
        timestamp = new Date;
        console.warn('timestamp', timestamp);
        console.warn(err.message);
        return proc.exit(1);
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
      a.use(mw.multiDomain);
      a.use(mw.ipLookup);
      a.use(mw.rateLimit);
      a.use(express.cookieParser());
      a.set('view engine', 'jade');
      a.set('views', 'app/views');
      a.enable('json callback');
      a.enable('trust proxy');
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
        return proc.exit(1);
      };
    };
    if (proc.env.NODE_ENV === 'production') {
      app.error(errHandler(function(res){
        return res.send(html_50x, 500);
      }));
    }
    require()('./routes');
    cacheApp.use(express['static']('public', {
      maxAge: 7200 * 1000
    }));
    redirToWww.all('*', function(req, res){
      var protocol, host, uri, url;
      protocol = req.headers['x-forwarded-proto'] || 'http';
      host = req.host;
      uri = req.url;
      url = "https://" + host + uri;
      return res.redirect(url, 301);
    });
    sock = express();
    for (i$ = 0, len$ = (ref$ = ['pbstage.com', 'pb.com', cvars.host]).length; i$ < len$; ++i$) {
      domain = ref$[i$];
      sock.use(express.vhost("m." + domain, redirToWww)).use(express.vhost(domain, redirToWww)).use(express.vhost("www." + domain, app));
      for (j$ = 0, len1$ = (ref1$ = ['', 2, 3, 4, 5]).length; j$ < len1$; ++j$) {
        i = ref1$[j$];
        sock.use(express.vhost(cvars.cache_prefix + "" + i + "." + domain, cacheApp));
      }
    }
    sock.listen(proc.env['NODE_PORT'] || cvars.port);
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
