## BEG PURE FUNCTIONS ##

# will not mutate operand (similar to hashish.merge)
export merge = merge = (...args) ->
  r = (rval, hval) -> rval <<< hval
  args.reduce r, {}

# turn a title into a unique uri
export title2slug = (title, id) ->
  title = title.to-lower-case!
  title = title.replace new RegExp('[^a-z0-9 ]'), ''
  title = title.replace new RegExp(' +'), '-'
  title = title.slice 0, 30
  title.concat "-#{id}"

## END PURE FUNCTIONS ##

top-forums-recent = (limit) ->
  sql = '''
  SELECT * FROM forums
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY created DESC, id ASC
  LIMIT $2
  '''
  (...args) -> plv8.execute sql, args.concat([limit])

top-forums-active = (limit) ->
  sql = '''
  SELECT
    f.*,
    (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=f.id) sort
  FROM forums f
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY sort
  LIMIT $2
  '''
  (...args) -> plv8.execute sql, args.concat([limit])

sub-forums = ->
  sql = '''
  SELECT *
  FROM forums
  WHERE parent_id=$1
  ORDER BY created DESC, id DESC
  '''
  plv8.execute sql, arguments

top-posts-recent = (limit) ->
  sql = '''
  SELECT
    p.*,
    a.name user_name
  FROM posts p, aliases a
  WHERE a.user_id=p.user_id
    AND a.site_id=1
    AND p.parent_id IS NULL
    AND p.forum_id=$1
  ORDER BY created DESC, id DESC
  LIMIT $2
  '''
  (...args) -> plv8.execute sql, args.concat([limit])

top-posts-active = (limit) ->
  sql = '''
  SELECT
    p.*,
    a.name user_name,
    (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=$1) sort
  FROM posts p, aliases a
  WHERE a.user_id=p.user_id
    AND a.site_id=1
    AND p.parent_id IS NULL
    AND p.forum_id=$1
  ORDER BY sort
  LIMIT $2
  '''
  (...args) -> plv8.execute sql, args.concat([limit])

sub-posts = ->
  sql = '''
  SELECT p.*, a.name user_name
  FROM posts p, aliases a
  WHERE a.user_id=p.user_id
    AND a.site_id=1
    AND p.parent_id=$1
  ORDER BY created DESC, id DESC
  '''
  plv8.execute sql, arguments

# recurses to build entire comment tree
export sub-posts-tree = (parent-id) ->
  [merge(p, {posts: sub-posts-tree(p.id)}) for p in sub-posts(parent-id)]

# gets entire list of top posts and inlines all sub-posts to them
posts-tree = (forum-id, top-posts) ->
  [merge(p, {posts: sub-posts-tree(p.id)}) for p in top-posts]

decorate-forum = (f, top-posts-fun) ->
  merge f, {posts: posts-tree(f.id, top-posts-fun(f.id)), forums: [decorate-forum(sf, top-posts-fun) for sf in sub-forums(f.id)]}

export doc = ->
  if res = plv8.execute('SELECT json FROM docs WHERE site_id=$1 AND type=$2 AND key=$3', arguments)[0]
    JSON.parse(res.json)
  else
    null

export put-doc = (...args) ->
  insert-sql =
    'INSERT INTO docs (site_id, type, key, json) VALUES ($1, $2, $3, $4)'
  update-sql =
    'UPDATE docs SET json=$4 WHERE site_id=$1::bigint AND type=$2::varchar(64) AND key=$3::varchar(64)'

  args[2] = JSON.stringify args[2] if args[2]

  try
    plv8.subtransaction ->
      plv8.execute insert-sql, args
  catch
    plv8.execute update-sql, args

  true # rval

# single forum
forum-tree = (forum-id, top-posts-fun) ->
  sql = 'SELECT * FROM forums WHERE id=$1 LIMIT 1'
  if f = plv8.execute(sql, [forum-id])[0]
    decorate-forum(f, top-posts-fun)

# all forums for site
forums-tree = (site-id, top-posts-fun, top-forums-fun) ->
  [decorate-forum(f, top-posts-fun) for f in top-forums-fun(site-id)]

export build-forum-doc = (site-id, forum-id) ->
  ## XXX: should we have a custom menu routine ?? instead of piggybacking on to forums
  menu = forums-tree(site-id, top-posts-recent!, top-forums-recent!)

  build-forum-doc-for = (doctype, top-posts-fun) ~>
    forum = {forums: [forum-tree(forum-id, top-posts-fun)], menu}
    @put-doc site-id, doctype, forum-id, JSON.stringify(forum)

  build-forum-doc-for \forum_recent, top-posts-recent!
  build-forum-doc-for \forum_active, top-posts-active!
  true

export build-homepage-doc = (site-id) ->
  ## XXX: should we have a custom menu routine ?? instead of piggybacking on to forums
  menu = forums-tree(site-id, top-posts-recent!, top-forums-recent!)

  build-homepage-doc-for = (doctype, top-posts-fun, top-forums-fun) ~>
    forums = forums-tree(site-id, top-posts-fun, top-forums-fun)
    homepage = {forums, menu}
    @put-doc site-id, doctype, site-id, JSON.stringify(homepage)

  build-homepage-doc-for \homepage_recent, top-posts-recent(5), top-forums-recent!
  build-homepage-doc-for \homepage_active, top-posts-active(5), top-forums-active!
  true

