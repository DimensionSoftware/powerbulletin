(function(){
  var pv, post, out$ = typeof exports != 'undefined' && exports || this;
  pv = require('./pure-validations');
  out$.post = post = function(post){
    var errors;
    errors = pv.post(post);
    return errors;
  };
}).call(this);
