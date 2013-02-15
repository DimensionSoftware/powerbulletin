## BEG PURE FUNCTIONS ##

# will not mutate operand (similar to hashish.merge)
export merge = merge = (...args) ->
  r = (rval, hval) -> rval <<< hval
  args.reduce r, {}

## END PURE FUNCTIONS ##

top-forums = ->
  sql = '''
  SELECT * FROM forums
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY created DESC, id DESC
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

top-posts-recent = ->
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
  '''
  plv8.execute sql, arguments

top-posts-active = ->
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
  '''
  plv8.execute sql, arguments

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
posts-tree = (forum-id) ->
  [merge(p, {posts: sub-posts-tree(p.id)}) for p in top-posts-active(forum-id)]

decorate-forum = (f) ->
  merge f, {posts: posts-tree(f.id), forums: [decorate-forum(sf) for sf in sub-forums(f.id)]}

export doc = ->
  if res = plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', arguments)[0]
    JSON.parse(res.json)
  else
    null

export put-doc = ->
  insert-sql =
    'INSERT INTO docs (type, key, json) VALUES ($1, $2, $3)'
  update-sql =
    'UPDATE docs SET json=$3 WHERE type=$1::varchar(64) AND key=$2::varchar(64)'

  args = Array.prototype.slice.call(arguments)
  try
    plv8.subtransaction ->
      plv8.execute insert-sql, args
  catch
    plv8.execute update-sql, args

  true # rval

# single forum
export forum = (forum-id) ->
  sql = 'SELECT * FROM forums WHERE id=$1 LIMIT 1'
  if f = plv8.execute(sql, [forum-id])[0]
    decorate-forum(f)

# all forums for site
export forums = (site-id) ->
  [decorate-forum(f) for f in top-forums(site-id)]

export build-forum-doc = (forum-id) ->
  site-id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [forum-id])[0].site_id

  ## XXX: should we have a custom menu routine ?? instead of piggybacking on to forums
  menu = @forums(site-id)
  forum-doc = JSON.stringify {forums: [@forum(forum-id)], menu}
  @put-doc \forum_doc, forum-id, JSON.stringify(forum-doc)

export build-homepage-doc = (site-id) ->
  forums = @forums(site-id)
  menu = forums # replace this with something else in the future...
  homepage-doc = JSON.stringify {forums, menu}
  # XXX: needs to be multi-tennant-ized
  @put-doc \misc, \homepage, JSON.stringify(homepage-doc)

