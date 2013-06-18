(function(){
  var pv, post, censor, out$ = typeof exports != 'undefined' && exports || this;
  pv = require('./pure-validations');
  out$.post = post = function(post){
    var errors, authorizeTransient, site_id, uExists, tExists;
    errors = pv.post(post);
    authorizeTransient = plv8.find_function('procs.authorize_transient');
    site_id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [post.forum_id])[0].site_id;
    plv8.elog(WARNING, JSON.stringify(post));
    uExists = post.user_id ? !!plv8.execute('SELECT TRUE FROM users WHERE id=$1', [post.user_id]) : void 8;
    tExists = post.transient_owner ? authorizeTransient(post.transient_owner, site_id) : void 8;
    if (!(uExists || tExists)) {
      errors.push('Posting is not authorized');
    }
    return errors;
  };
  out$.censor = censor = function(post){
    var errors;
    errors = pv.censor(post);
    return errors;
  };
}).call(this);
