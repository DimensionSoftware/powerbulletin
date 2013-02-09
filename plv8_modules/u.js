(function(){
  var topForums, topPosts, subPosts, subPostsTree, posts, getDoc, putDoc, forums, out$ = typeof exports != 'undefined' && exports || this;
  topForums = function(){
    var sql;
    sql = 'SELECT * FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  topPosts = function(){
    var sql;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  subPosts = function(){
    var sql, subPosts;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id=$1\nORDER BY created DESC, id DESC';
    return subPosts = plv8.execute(sql, arguments);
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
  out$.getDoc = getDoc = function(){
    var res;
    if (res = plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', arguments)[0]) {
      return JSON.parse(res.json);
    } else {
      return null;
    }
  };
  out$.putDoc = putDoc = function(){
    var insertSql, updateSql, args, e;
    insertSql = 'INSERT INTO docs (type, key, json) VALUES ($1, $2, $3) RETURNING json';
    updateSql = 'UPDATE docs SET json=$3 WHERE type=$1::varchar(64) AND key=$2::varchar(64)';
    args = Array.prototype.slice.call(arguments);
    try {
      return plv8.subtransaction(function(){
        return plv8.execute(insertSql, args);
      });
    } catch (e$) {
      e = e$;
      return plv8.execute(updateSql, args);
    }
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
