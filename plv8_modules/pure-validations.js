(function(){
  var post, out$ = typeof exports != 'undefined' && exports || this;
  out$.post = post = function(post){
    var errors;
    errors = [];
    if (!post.user_id) {
      errors.push('user_id cannot be blank');
    }
    if (!post.forum_id) {
      errors.push('forum_id cannot be blank');
    }
    if (!post.title) {
      errors.push('title cannot be blank');
    }
    if (!post.body) {
      errors.push('body cannot be blank');
    }
    return errors;
  };
}).call(this);
