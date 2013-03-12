## BEG PURE FUNCTIONS ##

# will not mutate operand (similar to hashish.merge)
export merge = merge = (...args) ->
  r = (rval, hval) -> rval <<< hval
  args.reduce r, {}

# turn a title into a unique uri
export title2slug = (title, id) ->
  title = title.to-lower-case!
  title = title.replace new RegExp('[^a-z0-9 ]', 'g'), ''
  title = title.replace new RegExp(' +', 'g'), '-'
  title = title.slice 0, 30
  if id
    title = title.concat "-#{id}"
  title

## END PURE FUNCTIONS ##

top-forums = (limit, fields='*') ->
  sql = """
  SELECT #{fields} FROM forums
  WHERE parent_id IS NULL AND site_id=$1
  ORDER BY created DESC, id ASC
  LIMIT $2
  """
  (...args) -> plv8.execute sql, args.concat([limit])

sub-forums = ->
  sql = '''
  SELECT *
  FROM forums
  WHERE parent_id=$1
  ORDER BY created DESC, id DESC
  '''
  plv8.execute sql, arguments

top-posts = (sort, limit, fields='p.*') ->
  sort-expr =
    switch sort
    | \recent   => 'p.created DESC, id ASC'
    | \popular  => '(SELECT (SUM(views) + COUNT(*)*2) FROM posts WHERE thread_id=p.thread_id GROUP BY thread_id) DESC'
    | otherwise => throw new Error "invalid sort for top-posts: #{sort}"

  sql = """
  SELECT
    #{fields},
    MIN(a.name) user_name,
    COUNT(p2.id) post_count
  FROM aliases a
  JOIN posts p ON a.user_id=p.user_id
  LEFT JOIN posts p2 ON p2.parent_id=p.id
  LEFT JOIN moderations m ON m.post_id=p.id
  WHERE a.site_id=1
    AND p.parent_id IS NULL
    AND p.forum_id=$1
    AND m.post_id IS NULL
  GROUP BY p.id
  ORDER BY #{sort-expr}
  LIMIT $2
  """
  (...args) -> plv8.execute sql, args.concat([limit])

sub-posts = (site-id, post-id, limit, offset) ->
  sql = '''
  SELECT p.*, a.name user_name
  FROM posts p
  JOIN aliases a ON a.user_id=p.user_id
  LEFT JOIN moderations m ON m.post_id=p.id
  WHERE a.site_id=$1
    AND p.parent_id=$2
    AND m.post_id IS NULL
  ORDER BY created ASC, id ASC
  LIMIT $3 OFFSET $4
  '''
  plv8.execute sql, [site-id, post-id, limit, offset]

# recurses to build entire comment tree
export sub-posts-tree = sub-posts-tree = (parent-id, depth=3) ->
  sp = sub-posts(1, parent-id, 25, 0)
  if depth <= 0
    # more-posts flag will be used to put 'load more' links,
    # vs not showing the 'load more' links when there are no children yet
    # we only show 'load more' links when we hit an empty child list
    # and if and only if more-posts flag is true
    [merge(p, {posts: [], more-posts: !!sub-posts(1, p.id, 25, 0).length}) for p in sp]
  else
    [merge(p, {posts: sub-posts-tree(p.id, depth - 1)}) for p in sp]

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

  args[3] = JSON.stringify args[3] if args[3]

  try
    plv8.subtransaction ->
      plv8.execute insert-sql, args
  catch
    plv8.execute update-sql, args

  true # rval

# single forum
forum-tree = (forum-id, top-posts-fun) ->
  sql = 'SELECT id,parent_id,title,slug,description,media_url,classes FROM forums WHERE id=$1 LIMIT 1'
  if f = plv8.execute(sql, [forum-id])[0]
    decorate-forum(f, top-posts-fun)

# all forums for site
forums-tree = (site-id, top-posts-fun, top-forums-fun) ->
  [decorate-forum(f, top-posts-fun) for f in top-forums-fun(site-id)]

export uri-for-forum = (forum-id) ->
  sql = 'SELECT parent_id, slug FROM forums WHERE id=$1'
  [{parent_id, slug}] = plv8.execute sql, [forum-id]
  if parent_id
    @uri-for-forum(parent_id) + '/' + slug
  else
    '/' + slug

export uri-for-post = (post-id, first-slug = null) ->
  sql = 'SELECT forum_id, parent_id, slug FROM posts WHERE id=$1'
  [{forum_id, parent_id, slug}] = plv8.execute sql, [post-id]
  if parent_id
    if first-slug
      @uri-for-post(parent_id, first-slug) # carry first slug thru
    else
      @uri-for-post(parent_id, slug) # set slug once, and only once at the beginning
  else
    if first-slug
      @uri-for-forum(forum_id) + '/t/' + slug + '/' + first-slug
    else
      @uri-for-forum(forum_id) + '/t/' + slug

export menu = (site-id) ->
  # XXX: forums should always list in the same order, get rid of top-forums, and list in static order
  forums-tree(site-id,
    top-posts(\recent, null, 'p.created,p.title,p.slug,p.id'),
    top-forums(null, 'id,title,slug,classes'))

export homepage-forums = (site-id) ->
  # XXX: forums should always list in the same order, get rid of top-forums, and list in static order
  forums-tree site-id, top-posts(\recent), top-forums!

# this is really for a single forum even though its called 'forums'
export forums = (forum-id, sort) ->
  ft = forum-tree forum-id, top-posts(sort)
  if ft then [ft] else []

export top-threads = (forum-id, sort) ->
  top-posts(sort) forum-id
