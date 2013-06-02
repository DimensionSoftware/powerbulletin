(function(){
  var os, fs, async, cluster, express, http, expressResource, stylus, fluidity, ioServer, elastic, connect, pg, v, m, salesApp, shelljs, ref$, code, output, proc, app, cacheApp, server, gracefulShutdown, html_50x, html_404, e, mw, numWorkers, workers, reapWorkers, i$, i, child;
  require('LiveScript');
  os = require('os');
  fs = require('fs');
  async = require('async');
  cluster = require('cluster');
  express = require('express');
  http = require('http');
  expressResource = require('express-resource');
  stylus = require('stylus');
  fluidity = require('fluidity');
  ioServer = require('./io-server');
  elastic = require('./elastic');
  connect = require('express/node_modules/connect');
  pg = require('./postgres');
  v = require('./varnish');
  m = require('./pb-models');
  salesApp = require('./sales-app');
  import$(global, require('prelude-ls'));
  shelljs = require('shelljs');
  ref$ = shelljs.exec('git rev-parse HEAD', {
    silent: true
  }), code = ref$.code, output = ref$.output;
  global.CHANGESET = output.trim();
  global.DISABLE_HTTP_CACHE = !(process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'staging' || process.env.TEST_HTTP_CACHE);
  proc = process;
  proc.on('uncaughtException', function(e){
    throw e;
  });
  app = global.app = express();
  cacheApp = express();
  server = null;
  gracefulShutdown = function(){
    console.warn('Graceful shutdown started');
    setTimeout(function(){
      console.warn("Forcing shutdown");
      return process.exit();
    }, 5000);
    return server.close(function(err){
      console.warn('Graceful shutdown finished');
      if (err) {
        console.warn(err);
      }
      return process.exit();
    });
  };
  html_50x = fs.readFileSync('public/50x.html').toString();
  html_404 = fs.readFileSync('public/404.html').toString();
  try {
    global.cvars = require('../config/common');
    import$(global.cvars, require("../config/" + (proc.env.NODE_ENV || 'development')));
    try {
      import$(global.cvars, require('../config/local'));
    } catch (e$) {
      e = e$;
    }
    cvars.env = proc.env.NODE_ENV;
    cvars.processStartDate = new Date();
  } catch (e$) {
    e = e$;
    console.log("Inspect config.json: " + e);
    return;
  }
  mw = require('./middleware');
  numWorkers = proc.env.NODE_WORKERS || cvars.workers;
  if (cluster.isMaster) {
    console.log("\n [1;37m.. ._________\nPowerBulletin [1;37;40m" + app.settings.env + "[0;m [1;37mon port [1;37;40m" + (proc.env['NODE_PORT'] || cvars.port) + "[0;m [1;37mx " + numWorkers);
    console.log("[1;30;30m @ " + new Date() + "[0;m");
    proc.title = 'pb-supervisor';
    app.configure('production', function(){
      var id, e;
      fs.writeFileSync(cvars.tmp + "/pb.pid", proc.pid);
      id = 'pb';
      try {
        return proc.setuid(id);
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
    for (i$ = 1; i$ <= numWorkers; ++i$) {
      i = i$;
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
    proc.title = "pb-worker";
    console.log("[1;30;30m  `+ worker " + proc.pid + "[0;m");
    pg.init(function(err){
      if (err) {
        throw err;
      }
      global.db = pg.procs;
      return m.init(function(err){
        if (err) {
          throw err;
        }
        (function(){
          var k, v;
          return import$(pg.procs, (function(){
            var ref$, results$ = {};
            for (k in ref$ = m) {
              v = ref$[k];
if (k != 'orm' && k != 'client' && k != 'driver') {
                results$[k] = v;
              }
            }
            return results$;
          }()));
        })();
        return v.init(function(err){
          if (err) {
            throw err;
          }
          v.banAll();
          return elastic.init(function(err){
            var i$, ref$, len$, a, errHandler, pbRoutes, errOrNotfound, maxAge, sock, i, this$ = this;
            if (err) {
              throw err;
            }
            global.elc = elastic.client;
            if (proc.env.NODE_ENV === 'production') {
              proc.on('uncaughtException', function(err){
                var timestamp;
                timestamp = new Date;
                console.warn('timestamp', timestamp);
                console.warn(err.message);
                console.warn('uncaught exception in worker, shutting down');
                return gracefulShutdown();
              });
              proc.on('SIGTERM', function(){
                console.warn('SIGTERM received by worker, shutting down');
                return gracefulShutdown();
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
            if (app.env === 'development' || app.env === void 8) {
              app.use(connect.logger({
                immediate: false,
                format: 'dev'
              }));
            }
            for (i$ = 0, len$ = (ref$ = [app]).length; i$ < len$; ++i$) {
              a = ref$[i$];
              a.use(mw.vars);
              a.use(mw.cvars);
              a.use(mw.multiDomain);
              a.use(mw.ipLookup);
              a.use(mw.rateLimit);
              a.set('view engine', 'jade');
              a.set('views', 'app/views');
              a.enable('json callback');
              a.enable('trust proxy');
            }
            errHandler = function(responder){
              return function(err, req, res, next){
                var timestamp, ref$;
                timestamp = new Date;
                console.error("\ntimestamp    : " + timestamp + "\nclient_ip    : " + req.headers['x-real-client-ip'] + "\nuser_agent   : " + req.headers['user-agent'] + "\nhttp_method  : " + req.method + "\nurl          : " + (req.headers.host + req.url) + "\nuser         : " + ((ref$ = req.user) != null ? ref$.name : void 8) + "\n\n" + err.stack);
                responder(res);
                return gracefulShutdown();
              };
            };
            pbRoutes = require('./pb-routes');
            errOrNotfound = function(err, req, res, next){
              var explain;
              if (err === 404) {
                return res.send(html_404, 404);
              } else {
                explain = errHandler(function(res){
                  return res.send(html_50x, 500);
                });
                return explain(err, req, res, next);
              }
            };
            app.use(errOrNotfound);
            salesApp.use(errOrNotfound);
            maxAge = DISABLE_HTTP_CACHE
              ? 0
              : (60 * 60 * 24 * 365) * 1000;
            cacheApp.use(express['static']('public', {
              maxAge: maxAge
            }));
            sock = express();
            for (i$ = 0, len$ = (ref$ = ['', 2, 3, 4, 5]).length; i$ < len$; ++i$) {
              i = ref$[i$];
              sock.use(express.vhost(cvars["cache" + i + "Url"].slice(2), cacheApp));
            }
            sock.use(express.vhost('sales.powerbulletin.com', salesApp));
            sock.use(app);
            server = http.createServer(sock);
            ioServer.init(server);
            return server.listen(proc.env['NODE_PORT'] || cvars.port);
          });
        });
      });
    });
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
