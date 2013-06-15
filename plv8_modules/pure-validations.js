(function(){
  var post, censor, out$ = typeof exports != 'undefined' && exports || this;
  out$.post = post = function(post){
    var errors;
    errors = [];
    if (!(post.user_id || post.transient_owner)) {
      errors.push('Must specify a user');
    }
    if (!post.forum_id) {
      errors.push('Forum cannot be blank');
    }
    if (!(post.title || post.parent_id)) {
      errors.push('Title cannot be blank');
    }
    if (!post.body) {
      errors.push('Body cannot be blank');
    }
    return errors;
  };
  out$.censor = censor = function(c){
    var errors;
    errors = [];
    if (!c.user_id) {
      errors.push('User cannot be blank');
    }
    if (!c.post_id) {
      errors.push('Post cannot be blank');
    }
    if (!c.reason) {
      errors.push('Reason cannot be blank');
    }
    return errors;
  };
}).call(this);
