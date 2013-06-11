(function(){
  var LiveScript, ServerApp, s;
  LiveScript = require('LiveScript');
  ServerApp = require('./ServerApp');
  s = new ServerApp(3000);
  s.start();
}).call(this);
