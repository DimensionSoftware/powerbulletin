(function(){
  var pv, post, censor, out$ = typeof exports != 'undefined' && exports || this;
  pv = require('./pure-validations');
  out$.post = post = function(post){
    var errors;
    errors = pv.post(post);
    return errors;
  };
  out$.censor = censor = function(post){
    var errors;
    errors = pv.censor(post);
    return errors;
  };
}).call(this);
