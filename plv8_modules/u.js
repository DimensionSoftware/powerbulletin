(function(){
  var merge, title2slug, topForumsRecent, topForumsActive, subForums, topPostsRecent, topPostsActive, subPosts, subPostsTree, postsTree, decorateForum, doc, putDoc, forumTree, forumsTree, uriForForum, uriForPost, menu, buildForumDocs, buildHomepageDoc, out$ = typeof exports != 'undefined' && exports || this, slice$ = [].slice;
  out$.merge = merge = merge = function(){
    var args, r;
    args = slice$.call(arguments);
    r = function(rval, hval){
      return import$(rval, hval);
    };
    return args.reduce(r, {});
  };
  out$.title2slug = title2slug = function(title, id){
    title = title.toLowerCase();
    title = title.replace(new RegExp('[^a-z0-9 ]', 'g'), '');
    title = title.replace(new RegExp(' +', 'g'), '-');
    title = title.slice(0, 30);
    if (id) {
      title = title.concat("-" + id);
    }
    return title;
  };
  topForumsRecent = function(limit, fields){
    var sql;
    fields == null && (fields = '*');
    sql = "SELECT " + fields + " FROM forums\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY created DESC, id ASC\nLIMIT $2";
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  topForumsActive = function(limit){
    var sql;
    sql = 'SELECT\n  f.*,\n  (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=f.id AND archived=\'f\') sort\nFROM forums f\nWHERE parent_id IS NULL AND site_id=$1\nORDER BY sort\nLIMIT $2';
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
  out$.topPostsRecent = topPostsRecent = topPostsRecent = function(limit, fields){
    var sql;
    fields == null && (fields = 'p.*');
    sql = "SELECT\n  " + fields + ",\n  MIN(a.name) user_name,\n  COUNT(p2.id) post_count\nFROM aliases a,\n     posts p LEFT JOIN posts p2 ON p2.parent_id = p.id\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\n  AND p.archived='f'\nGROUP BY p.id\nORDER BY p.created DESC, id ASC\nLIMIT $2";
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  topPostsActive = function(limit, fields){
    var sql;
    fields == null && (fields = 'p.*');
    sql = "SELECT\n  " + fields + ",\n  MIN(a.name) user_name,\n  COUNT(p2.id) post_count,\n  (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=$1 AND archived='f') sort\nFROM aliases a,\n     posts p LEFT JOIN posts p2 ON p2.parent_id = p.id\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id IS NULL\n  AND p.forum_id=$1\n  AND p.archived='f'\nGROUP BY p.id\nORDER BY sort\nLIMIT $2";
    return function(){
      var args;
      args = slice$.call(arguments);
      return plv8.execute(sql, args.concat([limit]));
    };
  };
  subPosts = function(){
    var sql;
    sql = 'SELECT p.*, a.name user_name\nFROM posts p, aliases a\nWHERE a.user_id=p.user_id\n  AND a.site_id=1\n  AND p.parent_id=$1\n  AND p.archived=\'f\'\nORDER BY created DESC, id ASC';
    return plv8.execute(sql, arguments);
  };
  out$.subPostsTree = subPostsTree = subPostsTree = function(parentId, depth){
    var sp, i$, len$, p, results$ = [];
    depth == null && (depth = 3);
    sp = subPosts(parentId);
    if (depth <= 0) {
      for (i$ = 0, len$ = sp.length; i$ < len$; ++i$) {
        p = sp[i$];
        results$.push(merge(p, {
          posts: [],
          morePosts: !!subPosts(p.id).length
        }));
      }
      return results$;
    } else {
      for (i$ = 0, len$ = sp.length; i$ < len$; ++i$) {
        p = sp[i$];
        results$.push(merge(p, {
          posts: subPostsTree(p.id, depth - 1)
        }));
      }
      return results$;
    }
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
    if (res = plv8.execute('SELECT json FROM docs WHERE site_id=$1 AND type=$2 AND key=$3', arguments)[0]) {
      return JSON.parse(res.json);
    } else {
      return null;
    }
  };
  out$.putDoc = putDoc = function(){
    var args, insertSql, updateSql, e;
    args = slice$.call(arguments);
    insertSql = 'INSERT INTO docs (site_id, type, key, json) VALUES ($1, $2, $3, $4)';
    updateSql = 'UPDATE docs SET json=$4 WHERE site_id=$1::bigint AND type=$2::varchar(64) AND key=$3::varchar(64)';
    if (args[3]) {
      args[3] = JSON.stringify(args[3]);
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
    sql = 'SELECT id,parent_id,title,slug,description,media_url,classes FROM forums WHERE id=$1 LIMIT 1';
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
  out$.uriForForum = uriForForum = function(forumId){
    var sql, ref$, parent_id, slug;
    sql = 'SELECT parent_id, slug FROM forums WHERE id=$1';
    ref$ = plv8.execute(sql, [forumId])[0], parent_id = ref$.parent_id, slug = ref$.slug;
    if (parent_id) {
      return this.uriForForum(parent_id) + '/' + slug;
    } else {
      return '/' + slug;
    }
  };
  out$.uriForPost = uriForPost = function(postId, firstSlug){
    var sql, ref$, forum_id, parent_id, slug;
    firstSlug == null && (firstSlug = null);
    sql = 'SELECT forum_id, parent_id, slug FROM posts WHERE id=$1';
    ref$ = plv8.execute(sql, [postId])[0], forum_id = ref$.forum_id, parent_id = ref$.parent_id, slug = ref$.slug;
    if (parent_id) {
      if (firstSlug) {
        return this.uriForPost(parent_id, firstSlug);
      } else {
        return this.uriForPost(parent_id, slug);
      }
    } else {
      if (firstSlug) {
        return this.uriForForum(forum_id) + '/t/' + slug + '/' + firstSlug;
      } else {
        return this.uriForForum(forum_id) + '/t/' + slug;
      }
    }
  };
  out$.menu = menu = function(siteId){
    return forumsTree(siteId, topPostsRecent(null, 'p.created,p.title,p.slug,p.id'), topForumsRecent(null, 'id,title,slug,classes'));
  };
  out$.buildForumDocs = buildForumDocs = function(siteId, forumId){
    var menu, buildForumDocsFor, this$ = this;
    menu = this.menu(siteId);
    buildForumDocsFor = function(doctype, topPostsFun){
      var forum, posts;
      forum = {
        forums: [forumTree(forumId, topPostsFun)],
        menu: menu
      };
      this$.putDoc(siteId, "forum_" + doctype, forumId, JSON.stringify(forum));
      posts = topPostsFun(forumId);
      return this$.putDoc(siteId, "threads_" + doctype, forumId, JSON.stringify(posts));
    };
    buildForumDocsFor('recent', topPostsRecent());
    buildForumDocsFor('active', topPostsActive());
    return true;
  };
  out$.buildHomepageDoc = buildHomepageDoc = function(siteId){
    var menu, buildHomepageDocFor, this$ = this;
    menu = this.menu(siteId);
    buildHomepageDocFor = function(doctype, topPostsFun, topForumsFun){
      var forums, homepage;
      forums = forumsTree(siteId, topPostsFun, topForumsFun);
      homepage = {
        forums: forums,
        menu: menu
      };
      return this$.putDoc(siteId, doctype, siteId, JSON.stringify(homepage));
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
