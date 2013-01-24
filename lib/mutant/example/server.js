require("LiveScript");
util = require('util');
http = require('http');
app  = require("./app/app.ls").app;

http.createServer(app).listen(app.get('port'), function(){
  console.log(util.format("Express server listening on port %d in %s mode", app.get('port'), app.settings.env))
})
