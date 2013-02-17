(function(){
  var merge, topForumsRecent, topForumsActive, subForums, topPostsRecent, topPostsActive, subPosts, subPostsTree, postsTree, decorateForum, doc, putDoc, forumTree, forumsTree, buildForumDoc, buildHomepageDoc, out$ = typeof exports != 'undefined' && exports || this, slice$ = [].slice;
  out$.merge = merge = merge = function(){
    var args, r;
    args = slice$.call(arguments);
    r = function(rval, hval){
      return import$(rval, hval);
    };
    return args.reduce(r, {});
  };
  topForumsRecent = function(limit){
    var sql;
    sql = 'SELECT * FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id ASC\nLIMIT $2';
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  topForumsActive = function(limit){
    var sql;
    sql = 'SELECT\n  f.*,\n  (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=f.id) sort\nFROM forums f\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY sort\nLIMIT $2';
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  subForums = function(){
    var sql;
    sql = 'SELECT *\nFROM forums\nWHERE parent_id=$1\nORDER BY created DESC, id DESC';
    return plv8.execute(sql, arguments);
  };
  topPostsRecent = function(limit){
    var sql;
    sql = 'SELECT\n  p.*,\n  a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\nORDER BY created DESC, id DESC\nLIMIT $2';
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  topPostsActive = function(limit){
    var sql;
    sql = 'SELECT\n  p.*,\n  a.name user_name,\n  (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=$1) sort\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\nORDER BY sort\nLIMIT $2';
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
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
      results$.push(merge(p, {
        posts: subPostsTree(p.id)
      }));
    }
    return results$;
  };
  postsTree = function(forumId, topPosts){
    var i$, len$, p, results$ = [];
    for (i$ = 0, len$ = topPosts.length; i$ < len$; ++i$) {
      p = topPosts[i$];
      results$.push(merge(p, {
        posts: subPostsTree(p.id)
      }));
    }
    return results$;
  };
  decorateForum = function(f, topPostsFun){
    var sf;
    return merge(f, {
      posts: postsTree(f.id, topPostsFun(f.id)),
      forums: (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = subForums(f.id)).length; i$ < len$; ++i$) {
          sf = ref$[i$];
          results$.push(decorateForum(sf, topPostsFun));
        }
        return results$;
      }())
    });
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
    var args, insertSql, updateSql, e;
    args = slice$.call(arguments);
    insertSql = 'INSERT INTO docs (type, key, json) VALUES ($1, $2, $3)';
    updateSql = 'UPDATE docs SET json=$3 WHERE type=$1::varchar(64) AND key=$2::varchar(64)';
    if (args[2]) {
      args[2] = JSON.stringify(args[2]);
    }
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
  forumTree = function(forumId, topPostsFun){
    var sql, f;
    sql = 'SELECT * FROM forums WHERE id=$1 LIMIT 1';
    if (f = plv8.execute(sql, [forumId])[0]) {
      return decorateForum(f, topPostsFun);
    }
  };
  forumsTree = function(siteId, topPostsFun, topForumsFun){
    var i$, ref$, len$, f, results$ = [];
    for (i$ = 0, len$ = (ref$ = topForumsFun(siteId)).length; i$ < len$; ++i$) {
      f = ref$[i$];
      results$.push(decorateForum(f, topPostsFun));
    }
    return results$;
  };
  out$.buildForumDoc = buildForumDoc = function(forumId){
    var siteId, menu, buildForumDocFor, this$ = this;
    siteId = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [forumId])[0].site_id;
    menu = forumsTree(siteId, topPostsRecent(), topForumsRecent());
    buildForumDocFor = function(doctype, topPostsFun){
      var forum;
      forum = {
        forums: [forumTree(forumId, topPostsFun)],
        menu: menu
      };
      return this$.putDoc(doctype, forumId, JSON.stringify(forum));
    };
    buildForumDocFor('forum_recent', topPostsRecent());
    buildForumDocFor('forum_active', topPostsActive());
    return true;
  };
  out$.buildHomepageDoc = buildHomepageDoc = function(siteId){
    var menu, buildHomepageDocFor, this$ = this;
    menu = forumsTree(siteId, topPostsRecent(), topForumsRecent());
    buildHomepageDocFor = function(doctype, topPostsFun, topForumsFun){
      var forums, homepage;
      forums = forumsTree(siteId, topPostsFun, topForumsFun);
      homepage = {
        forums: forums,
        menu: menu
      };
      return this$.putDoc(doctype, siteId, JSON.stringify(homepage));
    };
    buildHomepageDocFor('homepage_recent', topPostsRecent(5), topForumsRecent());
    buildHomepageDocFor('homepage_active', topPostsActive(5), topForumsActive());
    return true;
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
