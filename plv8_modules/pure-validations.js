(function(){
  var post, censor, out$ = typeof exports != 'undefined' && exports || this;
  out$.post = post = function(post){
    var errors;
    errors = [];
    if (!(post.user_id || post.transient_owner)) {
      errors.push('must specify a user_id or transient_owner');
    }
    if (!post.forum_id) {
      errors.push('forum_id cannot be blank');
    }
    if (!(post.title || post.parent_id)) {
      errors.push('must specify a title or parent_id');
    }
    if (!post.body) {
      errors.push('body cannot be blank');
    }
    return errors;
  };
  out$.censor = censor = function(c){
    var errors;
    errors = [];
    if (!c.user_id) {
      errors.push('user_id cannot be blank');
    }
    if (!c.post_id) {
      errors.push('post_id cannot be blank');
    }
    if (!c.reason) {
      errors.push('reason cannot be blank');
    }
    return errors;
  };
}).call(this);
