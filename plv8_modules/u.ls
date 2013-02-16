## BEG PURE FUNCTIONS ##

# will not mutate operand (similar to hashish.merge)
export merge = merge = (...args) ->
  r = (rval, hval) -> rval <<< hval
  args.reduce r, {}

## END PURE FUNCTIONS ##

top-forums-recent = ->
  sql = '''
  SELECT * FROM forums
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY created DESC, id ASC
  '''
  plv8.execute sql, arguments

top-forums-active = ->
  sql = '''
  SELECT
    f.*,
    (SELECT AVG(EXTRACT(EPOCH FROM created)) FROM posts WHERE forum_id=f.id) sort
  FROM forums f
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY sort
  '''
  plv8.execute sql, arguments

sub-forums = ->
  sql = '''
  SELECT *
  FROM forums
  WHERE parent_id=$1
  ORDER BY created DESC, id DESC
  '''
  plv8.execute sql, arguments

top-posts-recent-fn = (limit='') ->
  limit = " LIMIT #{limit}" if limit
  f = ->
    sql = """
    SELECT
      p.*,
      a.name user_name
    FROM posts p, aliases a
    WHERE a.user_id=p.user_id
      AND a.site_id=1
      AND p.parent_id IS NULL
      AND p.forum_id=$1
    ORDER BY created DESC, id DESC
    #{limit}
    """
    plv8.execute sql, arguments
top-posts-recent = top-posts-recent-fn!

top-posts-active-fn = (limit='') ->
  limit = " LIMIT #{limit}" if limit
  f = ->
    sql = """
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
    #{limit}
    """
    plv8.execute sql, arguments
top-posts-active = top-posts-recent-fn!

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
sub-posts-tree = (parent-id) ->
  [merge(p, {posts: sub-posts-tree(p.id)}) for p in sub-posts(parent-id)]

# gets entire list of top posts and inlines all sub-posts to them
posts-tree = (forum-id, top-posts) ->
  [merge(p, {posts: sub-posts-tree(p.id)}) for p in top-posts]

decorate-forum = (f, top-posts-fun) ->
  merge f, {posts: posts-tree(f.id, top-posts-fun(f.id)), forums: [decorate-forum(sf, top-posts-fun) for sf in sub-forums(f.id)]}

export doc = ->
  if res = plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', arguments)[0]
    JSON.parse(res.json)
  else
    null

export put-doc = (...args) ->
  insert-sql =
    'INSERT INTO docs (type, key, json) VALUES ($1, $2, $3)'
  update-sql =
    'UPDATE docs SET json=$3 WHERE type=$1::varchar(64) AND key=$2::varchar(64)'

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

export build-forum-doc = (forum-id) ->
  site-id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [forum-id])[0].site_id

  ## XXX: should we have a custom menu routine ?? instead of piggybacking on to forums
  menu = forums-tree(site-id, top-posts-recent, top-forums-recent)
  forum-doc = {forums: [forum-tree(forum-id, top-posts-recent)], menu}
  @put-doc \forum_doc, forum-id, JSON.stringify(forum-doc)

export build-homepage-doc = (site-id) ->
  build-homepage-doc-for = (doctype, top-posts-fun, top-forums-fun) ~>
    forums = forums-tree(site-id, top-posts-fun, top-forums-fun)
    menu = forums # replace this with something else in the future...
    homepage = {forums, menu}
    @put-doc doctype, site-id, JSON.stringify(homepage)

  build-homepage-doc-for \homepage_recent, top-posts-recent-fn(5), top-forums-recent
  build-homepage-doc-for \homepage_active, top-posts-active-fn(5), top-forums-active
  true

