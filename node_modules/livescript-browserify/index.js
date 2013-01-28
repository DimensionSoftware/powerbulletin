(function(){
  var LiveScript;
  LiveScript = require('LiveScript');
  module.exports = function(bundle){
    return bundle.register('.ls', function(body, file){
      var js, error;
      try {
        js = LiveScript.compile(body, {
          filename: file
        });
      } catch (e$) {
        error = e$;
        bundle.emit('syntaxError', error);
      }
      return js;
    });
  };
}).call(this);
