(function(){
  var topForums, subForums, topPosts, subPosts, subPostsTree, posts, decorateForum, doc, putDoc, forum, forums, buildForumDoc, buildHomepageDoc, out$ = typeof exports != 'undefined' && exports || this;
  topForums = function(){
    var sql;
    sql = 'SELECT * FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  subForums = function(){
    var sql;
    sql = 'SELECT *\nFROM forums\nWHERE parent_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  topPosts = function(){
    var sql;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  subPosts = function(){
    var sql;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
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
  decorateForum = function(f){
    var sf;
    return f.posts = posts(f.id), f.forums = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = subForums(f.id)).length; i$ < len$; ++i$) {
        sf = ref$[i$];
        results$.push(decorateForum(sf));
      }
      return results$;
    }()), f;
  };
  out$.doc = doc = function(){
    var res;
    if (res = plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', arguments)[0]) {
      return JSON.parse(res.json);
    } else {
      return null;
    }
  };
  out$.putDoc = putDoc = function(){
    var insertSql, updateSql, args, e;
    insertSql = 'INSERT INTO docs (type, key, json) VALUES ($1, $2, $3)';
    updateSql = 'UPDATE docs SET json=$3 WHERE type=$1::varchar(64) AND key=$2::varchar(64)';
    args = Array.prototype.slice.call(arguments);
    try {
      plv8.subtransaction(function(){
        return plv8.execute(insertSql, args);
      });
    } catch (e$) {
      e = e$;
      plv8.execute(updateSql, args);
    }
    return true;
  };
  out$.forum = forum = function(forumId){
    var sql, f;
    sql = 'SELECT * FROM forums WHERE id=$1 LIMIT 1';
    if (f = plv8.execute(sql, [forumId])[0]) {
      return decorateForum(f);
    }
  };
  out$.forums = forums = function(siteId){
    var i$, ref$, len$, f, results$ = [];
    for (i$ = 0, len$ = (ref$ = topForums(siteId)).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push(decorateForum(f));
    }
    return results$;
  };
  out$.buildForumDoc = buildForumDoc = function(forumId){
    var siteId, menu, forumDoc;
    siteId = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [forumId])[0].site_id;
    menu = this.forums(siteId);
    forumDoc = JSON.stringify({
      forums: [this.forum(forumId)],
      menu: menu
    });
    return this.putDoc('forum_doc', forumId, JSON.stringify(forumDoc));
  };
  out$.buildHomepageDoc = buildHomepageDoc = function(siteId){
    var forums, menu, homepageDoc;
    forums = this.forums(siteId);
    menu = forums;
    homepageDoc = JSON.stringify({
      forums: forums,
      menu: menu
    });
    return this.putDoc('misc', 'homepage', JSON.stringify(homepageDoc));
  };
}).call(this);
