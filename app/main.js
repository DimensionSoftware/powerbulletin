(function(){
  var LiveScript, isStarting, s;
  LiveScript = require('LiveScript');
  function cleanRequireCache(){
    var k, ref$, v;
    for (k in ref$ = require.cache) {
      v = ref$[k];
      if (k.indexOf(process.cwd() + '/build') !== -1 || k.indexOf(process.cwd() + "/app") !== -1 || k.indexOf(process.cwd() + "/component") !== -1) {
        console.log('unrequiring: ' + k);
        delete require.cache[k];
      }
    }
  }
  function restart(){
    var load;
    load = function(){
      var ServerApp;
      isStarting = true;
      ServerApp = require('./ServerApp');
      s = new ServerApp(process.argv[2] || parseInt(process.env.NODE_PORT) || 3000);
      return s.start(function(){
        return isStarting = false;
      });
    };
    if (isStarting) {
      console.warn("Still restarting ...");
    } else {
      if (s) {
        s.stop(function(){
          cleanRequireCache();
          return load();
        });
      } else {
        load();
      }
    }
  }
  process.on('SIGHUP', restart);
  restart();
}).call(this);
