(function(){
  var topForums, topPosts, subPosts, subPostsTree, posts, forums, out$ = typeof exports != 'undefined' && exports || this;
  topForums = function(siteId){
    var sql;
    sql = 'SELECT * FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, [siteId]);
  };
  topPosts = function(forumId){
    var sql;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, [forumId]);
  };
  subPosts = function(parentId){
    var sql, subPosts;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id=$1\nORDER BY created DESC, id DESC';
    return subPosts = plv8.execute(sql, [parentId]);
  };
  subPostsTree = function(parentId){
    var i$, ref$, len$, p, results$ = [];
    for (i$ = 0, len$ = (ref$ = subPosts(parentId)).length; i$ < len$; ++i$) {
      p = ref$[i$];
      results$.push((p.posts = subPostsTree(p.id), p));
    }
    return results$;
  };
  posts = function(forumId){
    var i$, ref$, len$, p, results$ = [];
    for (i$ = 0, len$ = (ref$ = topPosts(forumId)).length; i$ < len$; ++i$) {
      p = ref$[i$];
      results$.push((p.posts = subPostsTree(p.id), p));
    }
    return results$;
  };
  out$.forums = forums = function(siteId){
    var i$, ref$, len$, f, results$ = [];
    for (i$ = 0, len$ = (ref$ = topForums(siteId)).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push((f.posts = posts(f.id), f));
    }
    return results$;
  };
}).call(this);
