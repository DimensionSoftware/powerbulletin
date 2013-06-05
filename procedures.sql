DROP SCHEMA IF EXISTS procs CASCADE;
CREATE SCHEMA procs;

CREATE FUNCTION procs.find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON) RETURNS JSON AS $$
  thing = plv8.execute(sel, sel_params)
  return thing[0] if thing.length > 0
  plv8.execute(ins, ins_params)
  return plv8.execute(sel, sel_params)[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- Posts {{{
CREATE FUNCTION procs.owns_post(post_id JSON, user_id JSON) RETURNS JSON AS $$
  return unless post_id and user_id # guard
  return plv8.execute('SELECT id FROM posts WHERE id=$1 AND user_id=$2', [post_id, user_id])
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.post(id JSON) RETURNS JSON AS $$
  return {} unless id # guard
  sql = '''
  SELECT p.*,
  a.name AS user_name ,
  u.photo AS user_photo,
  (SELECT COUNT(*) FROM posts WHERE parent_id = p.id) AS post_count,
  ARRAY(SELECT tags.name FROM tags JOIN tags_posts ON tags.id = tags_posts.tag_id WHERE tags_posts.post_id = p.id) AS tags
  FROM posts p
  JOIN users u ON p.user_id = u.id
  JOIN aliases a ON u.id = a.user_id
  WHERE p.id = $1;
  '''
  return plv8.execute(sql, [id])?0
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.posts_by_user(usr JSON, page JSON, ppp JSON) RETURNS JSON AS $$
  require! u
  sql = '''
  SELECT
  p.*,
  a.name AS user_name ,
  u.photo AS user_photo,
  m.reason,
  (SELECT COUNT(*) FROM posts WHERE parent_id = p.id) AS post_count
  FROM posts p
  JOIN users u ON p.user_id = u.id
  JOIN aliases a ON u.id = a.user_id
  LEFT JOIN moderations m ON p.id=m.post_id
  WHERE p.forum_id IN (SELECT id FROM forums WHERE site_id = $1)
  AND a.name = $2
  ORDER BY p.created DESC
  LIMIT  $3
  OFFSET $4
  '''
  offset = (page - 1) * ppp
  posts = plv8.execute(sql, [usr.site_id, usr.name, ppp, offset])

  if posts.length
    # fetch thread & forum context
    thread-sql = """
      SELECT p.id,p.title,p.uri, a.user_id,a.name, f.uri furi,f.title ftitle
      FROM posts p
        LEFT JOIN aliases a ON a.user_id=p.user_id
        LEFT JOIN posts f ON f.id=p.forum_id
      WHERE p.id IN (#{(u.unique [p.thread_id for p,i in posts]).join(', ')})
    """
    ctx = plv8.execute(thread-sql, [])

    # hash for o(n) + o(1) * posts -> thread mapping
    lookup = {[v.id, v] for k,v of ctx}
    for p in posts
      t = lookup[p.thread_id] # thread
      [p.thread_uri, p.thread_title, p.thread_username, p.forum_uri, p.forum_title] =
        [t.uri, t.title, t.name, t.furi, t.ftitle]

  return posts
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.posts_by_user_pages_count(usr JSON, ppp JSON) RETURNS JSON AS $$
  sql = '''
  SELECT
  COUNT(p.id) as c
  FROM posts p
  JOIN users u ON p.user_id = u.id
  JOIN aliases a ON u.id = a.user_id
  WHERE p.forum_id IN (SELECT id FROM forums WHERE site_id = $1)
  AND a.name = $2
  '''
  res   = plv8.execute(sql, [usr.site_id, usr.name])
  c     = res[0]?c or 0
  pages = Math.ceil(c / ppp)
  return pages
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.edit_post(usr JSON, post JSON) RETURNS JSON AS $$
  require! <[u validations]>
  errors = validations.post(post)

  # check ownership & access
  fn = plv8.find_function('procs.owns_post')
  r = fn(post.id, usr.id)
  errors.push "Higher access required" unless r.length
  res = {success: !errors.length, errors}
  if res.success 
    sqlres = plv8.execute('UPDATE posts SET title=$1,body=$2,html=$3 WHERE id=$4 RETURNING id,title,body,forum_id', [post.title, post.body, post.html, post.id])

    res <<< sqlres
  return res
$$ LANGUAGE plls IMMUTABLE STRICT;

-- THIS IS ONLY FOR TOPLEVEL POSTS
-- TODO: needs to support nested posts also, and update correct thread-id
-- @param Object post
--   @param Number forum_id
--   @param Number user_id
--   @param String title
--   @param String body
--   @param String html
-- @returns Object
CREATE FUNCTION procs.add_post(post JSON) RETURNS JSON AS $$
  var uri
  require! <[u validations]>
  errors = validations.post(post)
  if !errors.length
    if site-id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [post.forum_id])[0]?.site_id
      [{nextval}] = plv8.execute("SELECT nextval('posts_id_seq')", [])

      forum-id = parse-int(post.forum_id) or null
      parent-id = parse-int(post.parent_id) or null
      if post.parent_id
        r = plv8.execute('SELECT thread_id FROM posts WHERE id=$1', [post.parent_id])
        unless thread_id = r.0?thread_id
          errors.push 'Invalid thread ID'; return {success: !errors.length, errors}
        # child posts use id for slug
        # XXX: todo flatten this into a hash or singular id in the uri instead of nesting subcomments
        slug = nextval
      else
        thread_id = nextval
        # top-level posts use title text for generating a slug
        slug = u.title2slug(post.title) # try pretty version first

      # TODO: don't use numeric identifier in slug unless you have to, use subtransaction to catch the case and use the more-unique version
      # TODO: kill comment url recursions and go flat with the threads side of things (hashtag like reddit?) or keep it the same
      #       its a question of url length

      sql = '''
      INSERT INTO posts (id, thread_id, user_id, forum_id, parent_id, title, slug, body, html, media_url, ip)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      '''

      params =
        * nextval
        * thread_id
        * parse-int(post.user_id) or null
        * forum-id
        * parent-id
        * post.title
        * slug
        * post.body or ''
        * post.html or ''
        * post.media_url or null
        * post.ip

      plv8.execute(sql, params)

      # the post must be inserted before uri-for-post will work, thats why uri is a NULLABLE column
      try
        plv8.subtransaction ->
          uri := u.uri-for-post(nextval)
          plv8.execute 'UPDATE posts SET uri=$1 WHERE id=$2', [uri, nextval]
      catch
        slug = u.title2slug(post.title, nextval) # add uniqueness since there is one which exists already
        plv8.execute 'UPDATE posts SET slug=$1 WHERE id=$2', [slug, nextval]
        uri := u.uri-for-post(nextval)
        plv8.execute 'UPDATE posts SET uri=$1 WHERE id=$2', [uri, nextval]

      # associate tags to post
      if post.tags
        add-tags-to-post = plv8.find_function('procs.add_tags_to_post')
        add-tags-to-post nextval, post.tags

    else
      errors.push "forum_id invalid: #{post.forum_id}"

  return {success: !errors.length, errors, id: nextval, uri}
$$ LANGUAGE plls IMMUTABLE STRICT;

-- Add tags to system
-- @param   Array  tags    an array of tags as strings
-- @returns Array          an array of tag objects
CREATE FUNCTION procs.add_tags(tags JSON) RETURNS JSON AS $$
  add-tag = (tag) ->
    sql = '''
    INSERT INTO tags (name) SELECT $1::varchar WHERE NOT EXISTS (SELECT name FROM tags WHERE name = $1) RETURNING *
    '''
    res = plv8.execute sql, [tag]
    if res.length == 0
      res2 = plv8.execute 'SELECT * FROM tags WHERE name = $1', [tag]
      return res2[0]
    else
      return res[0]
  return [ add-tag t for t in tags ]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- Associate tags to a post
-- @param   Number post_id
-- @param   Array  tags    an array of tags as strings
-- @returns Array          an array of tag objects
CREATE FUNCTION procs.add_tags_to_post(post_id JSON, tags JSON) RETURNS JSON AS $$
  require! u
  if not tags or tags.length == 0 then return null
  unique-tags = u.unique tags
  add-tags    = plv8.find_function('procs.add_tags')
  added-tags  = add-tags unique-tags
  sql         = 'INSERT INTO tags_posts (tag_id, post_id) VALUES ' + (["($#{parse-int(i)+2}, $1)" for v,i in added-tags]).join(', ')
  params      = [post_id, ...(u.map (.id), added-tags)]
  res         = plv8.execute sql, params
  plv8.elog WARNING, "add-tags-to-post -> #{JSON.stringify({res, params})}"
  return added-tags
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.archive_post(post_id JSON) RETURNS JSON AS $$
  require! u
  [{forum_id}] = plv8.execute "SELECT forum_id FROM posts WHERE id=$1", [post_id]
  [{site_id}] = plv8.execute 'SELECT site_id FROM forums WHERE forum_id=$1', [forum_id]
  plv8.execute "UPDATE posts SET archived='t' WHERE id=$1", [post_id]
  return true
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.sub_posts_tree(site_id JSON, post_id JSON, fields JSON, lim JSON, oft JSON) RETURNS JSON AS $$
  require! u
  return u.sub-posts-tree site_id, post_id, fields, lim, oft
$$ LANGUAGE plls IMMUTABLE STRICT;
--}}}

CREATE FUNCTION procs.forum_dict(site_id JSON) RETURNS JSON AS $$
  rows = plv8.execute "SELECT id, title FROM forums WHERE site_id=$1", [site_id]
  return {[r.id, r.title] for r in rows}
$$ LANGUAGE plls IMMUTABLE STRICT;

-- Users & Aliases {{{

-- Find a user by auths.type and auths.id
-- However, more information should be provided in case a new user needs to be created.
-- @param Object usr
--   @param String type         auths.type (facebook|google|twitter|local)
--   @param Number id           auths.id (3rd party user id)
--   @param JSON   profile      auths.profile (3rd party profile object)
--   @param Number site_id      aliases.site_id
--   @param String name         aliases.name
--   @param String verify       aliases.verify
CREATE FUNCTION procs.find_or_create_user(usr JSON) RETURNS JSON AS $$
  sel = '''
  SELECT u.id, u.created, a.site_id, a.name, auths.type, auths.profile
  FROM users u
    LEFT JOIN aliases a ON a.user_id = u.id
    LEFT JOIN auths ON auths.user_id = u.id
  WHERE auths.type = $1
  AND auths.id = $2
  '''
  sel-params =
    * usr.type
    * usr.id

  ins = '''
  WITH u AS (
      INSERT INTO users DEFAULT VALUES
        RETURNING id
    ), a AS (
      INSERT INTO auths (id, user_id, type, profile)
        SELECT $1::decimal, u.id, $2::varchar, $3::json FROM u
        RETURNING *
    )
  INSERT INTO aliases (user_id, site_id, name, verify)
    SELECT u.id, $4::bigint, $5::varchar, $6::varchar FROM u;
  '''
  ins-params =
    * usr.id
    * usr.type
    * JSON.stringify(usr.profile)
    * usr.site_id
    * usr.name
    * usr.verify

  find-or-create = plv8.find_function('procs.find_or_create')
  _u = find-or-create(sel, sel-params, ins, ins-params)
  if _u
    change-avatar = plv8.find_function('procs.change_avatar')
    change-avatar _u, '/images/profile.jpg'
  return _u
$$ LANGUAGE plls IMMUTABLE STRICT;

-- register_local_user(usr)
--
-- Find a user by auths.type and auths.id
-- However, more information should be provided in case a new user needs to be created.
-- @param Object usr
--   @param String type         auths.type (facebook|google|twitter|local)
--   @param Number id           auths.id (3rd party user id)
--   @param JSON   profile      auths.profile (3rd party profile object)
--   @param Number site_id      aliases.site_id
--   @param String name         aliases.name
--   @param String verify       aliases.verify
CREATE FUNCTION procs.register_local_user(usr JSON) RETURNS JSON AS $$
  # guard user.email & alias.name
  errors = []
  if ((plv8.execute 'SELECT id FROM users WHERE email=$1::varchar', [usr.email]).length)
    errors.push msg:'Email in-use'
  if ((plv8.execute 'SELECT user_id FROM aliases WHERE name=$1::varchar', [usr.name]).length)
    errors.push msg:'User name in-use'
  if errors.length then return {success:false, errors}

  ins = '''
  WITH u AS (
      INSERT INTO users (email) VALUES ($1)
        RETURNING id
    ), a AS (
      INSERT INTO auths (id, user_id, type, profile)
        SELECT u.id, u.id, $2::varchar, $3::json FROM u
        RETURNING *
    )
  INSERT INTO aliases (user_id, site_id, name, verify)
    SELECT u.id, $4::bigint, $5::varchar, $6::varchar FROM u
    RETURNING *
  '''
  ins-params =
    * usr.email
    * usr.type
    * JSON.stringify(usr.profile)
    * usr.site_id
    * usr.name
    * usr.verify
  [_u] = plv8.execute ins, ins-params
  if _u
    _u.id = _u.user_id
    change-avatar = plv8.find_function('procs.change_avatar')
    change-avatar _u, '/images/profile.jpg'
  return _u
$$ LANGUAGE plls IMMUTABLE STRICT;

-- XXX - need site_id
CREATE FUNCTION procs.unique_name(usr JSON) RETURNS JSON AS $$
  sql = '''
  SELECT name FROM aliases WHERE name=$1 AND site_id=$2
  '''
  [n,i]=[usr.name,0]
  while plv8.execute(sql, [n, usr.site_id])[0]
    n="#{usr.name}#{++i}"
  return JSON.stringify n # XXX why stringify??!
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.name_exists(usr JSON) RETURNS JSON AS $$
  sql = '''
  SELECT user_id, u.email, name, verify
  FROM aliases
  LEFT JOIN users u ON user_id = u.id
  WHERE email = $1 AND site_id = $2
  '''
  plv8.elog WARNING, sql
  r = plv8.execute sql, [usr.email, usr.site_id]
  if !!r.length
    return r[0]
  else
    return 0 # relying on 0 to be false
$$ LANGUAGE plls IMMUTABLE STRICT;

-- change alias
CREATE FUNCTION procs.change_alias(usr JSON) RETURNS JSON AS $$
  sql = '''
  UPDATE aliases SET name = $1 WHERE user_id = $2 AND site_id = $3
    RETURNING *
  '''
  return plv8.execute(sql, [usr.name, usr.user_id, usr.site_id])
$$ LANGUAGE plls IMMUTABLE STRICT;

-- change avatar
CREATE FUNCTION procs.change_avatar(usr JSON, path JSON) RETURNS JSON AS $$
  sql = '''
  UPDATE users SET photo = $1 WHERE id = $2
    RETURNING *
  '''
  return plv8.execute(sql, [path, usr.id])
$$ LANGUAGE plls IMMUTABLE STRICT;

-- find an alias by site_id and verify string
CREATE FUNCTION procs.alias_unique_hash(field JSON, site_id JSON, hash JSON) RETURNS JSON AS $$
  sql = """
  SELECT #field FROM aliases WHERE site_id = $1 AND #field = $2
  """
  return plv8.execute(sql, [site_id, hash])[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- find an alias by site_id and verify string
CREATE FUNCTION procs.alias_blank(usr JSON) RETURNS JSON AS $$
  sql = """
  UPDATE aliases SET forgot = NULL WHERE user_id = $1 AND site_id = $2 RETURNING *
  """
  return plv8.execute(sql, [usr.id, usr.site_id])[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

--
CREATE FUNCTION procs.verify_user(site_id JSON, verify JSON) RETURNS JSON AS $$
  sql = '''
  UPDATE aliases SET verified = true WHERE site_id = $1 AND verify = $2 RETURNING *
  '''
  return plv8.execute(sql, [site_id, verify])[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- @param Object usr
--   @param String  name       user name
--   @param Integer site_id    site id
-- @returns Object user        user with all auth objects
CREATE FUNCTION procs.usr(usr JSON) RETURNS JSON AS $$
  [identifier-clause, params] =
    if usr.id
      ["u.id = $1", [usr.id, usr.site_id]]
    else if usr.name
      ["a.name = $1", [usr.name, usr.site_id]]
    else if usr.email
      ["u.email = $1", [usr.email, usr.site_id]]
    else if usr.forgot
      ["a.forgot = $1", [usr.forgot, usr.site_id]]

  sql = """
  SELECT
    u.id, u.photo, u.email,
    a.rights, a.name, a.created, a.site_id,
    (SELECT COUNT(*) FROM posts WHERE user_id = u.id AND site_id = $2) AS post_count,
    auths.type, auths.profile 
  FROM users u
  JOIN aliases a ON a.user_id = u.id
  LEFT JOIN auths ON auths.user_id = u.id
  WHERE #identifier-clause
  AND a.site_id = $2
  """
  auths = plv8.execute(sql, params)
  if auths.length == 0
    return null
  make-user = (memo, auth) ->
    memo.auths[auth.type] = auth.profile
    memo
  u =
    auths      : {}
    id         : auths.0?id
    site_id    : auths.0?site_id
    name       : auths.0?name
    photo      : auths.0?photo
    email      : auths.0?email
    rights     : auths.0?rights
    created    : auths.0?created
    post_count : auths.0?post_count
  user = auths.reduce make-user, u
  return user
$$ LANGUAGE plls IMMUTABLE STRICT;
--}}}
-- {{{ Sites & Domains
-- @param String domain
CREATE FUNCTION procs.site_by_domain(domain JSON) RETURNS JSON AS $$
  sql = """
  SELECT s.*, d.name AS current_domain
  FROM sites s JOIN domains d ON s.id = d.site_id
  WHERE d.name = $1
  """
  s = plv8.execute(sql, [ domain ])
  if s[0]
    domains_by_site_id = plv8.find_function 'procs.domains_by_site_id'
    s[0].domains = domains_by_site_id(s[0].id)
  return s[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- @param Integer id
CREATE FUNCTION procs.site_by_id(id JSON) RETURNS JSON AS $$
  sql = """
  SELECT * FROM sites WHERE id = $1
  """
  s = plv8.execute(sql, [ id ])
  if s[0]
    domains_by_site_id = plv8.find_function 'procs.domains_by_site_id'
    s[0].domains = domains_by_site_id(s[0].id)
  return s[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.site_update(site JSON) RETURNS JSON AS $$
  sql = """
  UPDATE sites SET name = $1, config = $2, user_id = $3 WHERE id = $4
    RETURNING *
  """
  s = plv8.execute(sql, [ site.name, site.config, site.user_id, site.id ])
  return s[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.domain_by_id(id JSON) RETURNS JSON AS $$
  sql = """
  SELECT * FROM domains WHERE id = $1
  """
  d = plv8.execute sql, [id]
  return d[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.domain_update(domain JSON) RETURNS JSON AS $$
  sql = """
  UPDATE domains SET name = $1, config = $2, site_id = $3 WHERE id = $4
    RETURNING *
  """
  d = plv8.execute sql, [domain.name, domain.config, domain.site_id, domain.id]
  return d[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.domains_by_site_id(id JSON) RETURNS JSON AS $$
  sql = """
  SELECT * FROM domains WHERE site_id = $1 ORDER BY name
  """
  return plv8.execute sql, [id]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.domains() RETURNS JSON AS $$
  sql = """
  SELECT name FROM domains
  """
  return plv8.execute(sql).map (d) -> d.name
$$ LANGUAGE plls IMMUTABLE STRICT;

-- }}}
-- {{{ Forums & Threads
CREATE FUNCTION procs.add_thread_impression(thread_id JSON) RETURNS JSON AS $$
  if not thread_id or thread_id is \undefined
    return false
  sql = '''
  UPDATE posts SET views = views + 1 WHERE id = $1 RETURNING *
  '''
  res = plv8.execute sql, [thread_id]
  return res[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.build_all_uris(site_id JSON) RETURNS JSON AS $$
  require! u
  forums = plv8.execute 'SELECT id FROM forums WHERE site_id=$1', [site_id]
  posts = plv8.execute 'SELECT p.id FROM posts p JOIN forums f ON f.id=forum_id WHERE f.site_id=$1', [site_id]

  for f in forums
    uri = u.uri-for-forum(f.id)
    plv8.execute 'UPDATE forums SET uri=$1 WHERE id=$2', [uri, f.id]

  for p in posts
    uri = u.uri-for-post(p.id)
    plv8.execute 'UPDATE posts SET uri=$1 WHERE id=$2', [uri, p.id]

  return true
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.ban_patterns_for_forum(forum_id JSON) RETURNS JSON AS $$
  if f = plv8.execute('SELECT parent_id, uri FROM forums WHERE id=$1', [forum_id])[0]
    bans = []
    bans.push '^/$' unless f.parent_id # sub-forums need not ban the homepage.. maybe??
    bans.push "^#{f.uri}" # anything that beings with forum uri
    return bans
  else
    return []
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.bans_for_post(post_id JSON, user_id JSON) RETURNS JSON AS $$
  sql = '''
  SELECT d.name AS host, f.uri AS url
  FROM domains d
  JOIN forums f ON d.site_id=f.site_id
  JOIN posts p ON f.id=p.forum_id
  WHERE p.id=$1
  '''
  bans = plv8.execute(sql, [post_id])

  for b in bans
    b.url = '^' + b.url
  
  # ban associated profile, too
  profiles = bans.map (b) ->
    {host:b.host, url:"^/user/#user_id"}

  return bans ++ profiles
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.menu(site_id JSON) RETURNS JSON AS $$
  require! u
  return u.menu site_id
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.homepage_forums(forum_id JSON, sort JSON) RETURNS JSON AS $$
  unless sort in [\popular \recent] then sort = \recent # guard
  require! u
  return u.homepage-forums forum_id, sort
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.forum_summary(forum_id JSON, thread_limit JSON, sort JSON) RETURNS JSON AS $$
  forumf = plv8.find_function('procs.forum')
  forum  = forumf(forum_id)

  sort-sql =
    switch sort or \recent
    | \recent   => 'p.created DESC, p.id ASC'
    | \popular  => '(SELECT (SUM(views) + COUNT(*)*2) FROM posts WHERE thread_id=p.thread_id GROUP BY thread_id) DESC, p.created DESC'
    | otherwise => throw new Error "invalid sort for top-posts: #{sort}"

  # This query can be moved into its own proc and generalized so that it can
  # provide a flat view of a thread.
  # XXX non-null media url sorted first/top in list
  sql = """
  SELECT
    p.*,
    a.name user_name,
    u.photo user_photo
  FROM posts p
  JOIN aliases a ON a.user_id = p.user_id
  JOIN users u ON u.id = a.user_id
  JOIN forums f ON f.id = p.forum_id
  JOIN sites s ON s.id = f.site_id
  LEFT JOIN moderations m ON m.post_id = p.id
  WHERE a.site_id = s.id
    AND p.forum_id = $1
    AND p.parent_id IS NULL
  ORDER BY (LENGTH(p.media_url) > 1) DESC, #sort-sql
  LIMIT $2
  """
  forum.posts = plv8.execute(sql, [forum_id, thread_limit])
  return [forum]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.site_summary(site_id JSON, thread_limit JSON, sort JSON) RETURNS JSON AS $$
  sort-sql =
    switch sort or \recent
    | \recent   => 'created DESC, id ASC'
    | \popular  => '(SELECT (SUM(views) + COUNT(*)*2) FROM posts WHERE forum_id=id GROUP BY forum_id) DESC, created DESC'
    | otherwise => throw new Error "invalid sort for top-posts: #{sort}"
  site-ids = plv8.execute "SELECT id FROM forums WHERE site_id=$1::bigint ORDER BY #sort-sql", [site_id]
  fn = plv8.find_function \procs.forum_summary
  return site-ids.map (-> fn(it.id, thread_limit, sort).0)
$$ LANGUAGE plls IMMUTABLE STRICT;


CREATE FUNCTION procs.top_threads(forum_id JSON, s JSON) RETURNS JSON AS $$
  require! u
  return u.top-threads forum_id, s
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.uri_to_forum_id(site_id JSON, uri JSON) RETURNS JSON AS $$
  require! u
  try
    [{id}] = plv8.execute 'SELECT id FROM forums WHERE site_id=$1 AND uri=$2', [site_id, uri]
    return id
  catch
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.forum(id JSON) RETURNS JSON AS $$
  return plv8.execute('SELECT * FROM forums WHERE id=$1', [id])[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.uri_to_post(site_id JSON, uri JSON) RETURNS JSON AS $$
  require! u
  try
    sql = '''
    SELECT p.*, u.photo user_photo, a.name user_name
    FROM posts p
    JOIN forums f ON p.forum_id=f.id
    LEFT JOIN moderations m ON m.post_id=p.id
    JOIN users u ON p.user_id=u.id
    JOIN aliases a ON a.user_id=u.id
    WHERE f.site_id=$1
      AND p.uri=$2
      --AND m.post_id IS NULL -- change to m.is_malicious (only malicious content & spam should be hidden from browsers & search engines)
    '''
    [post] = plv8.execute sql, [site_id, uri]
    return post
  catch
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

-- c is for 'command'
CREATE FUNCTION procs.censor(c JSON) RETURNS JSON AS $$
  require! {u, validations}

  sql = '''
  INSERT INTO moderations (user_id, post_id, reason)
  VALUES ($1, $2, $3)
  '''

  errors = validations.censor(c)

  if !errors.length
    try
      plv8.execute sql, [c.user_id, c.post_id, c.reason]
    catch
      return null
  return {success:!errors.length, errors}
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.sub_posts_count(parent_id JSON) RETURNS JSON AS $$
  sql = '''
  SELECT COUNT(*)
  FROM posts p
  LEFT JOIN moderations m ON m.post_id=p.id
  WHERE p.parent_id=$1
    AND m.post_id IS NULL
  '''
  [{count}] = plv8.execute sql, [parent_id]
  return count
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.idx_posts(lim JSON) RETURNS JSON AS $$
  sql = '''
  SELECT p.id, p.thread_id, p.forum_id, p.user_id, p.title, p.body, p.created,
         p.updated, p.uri, p.html, f.title forum_title, t.uri thread_uri,
         t.title thread_title, a.name user_name, u.photo user_photo
  FROM posts p
  JOIN forums f ON p.forum_id=f.id
  JOIN posts t ON p.thread_id=t.id
  JOIN users u ON p.user_id=u.id
  JOIN aliases a ON a.user_id=p.user_id
  WHERE p.index_dirty='t'
  ORDER BY updated
  LIMIT $1
  '''
  return plv8.execute sql, [lim]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- acknowledge / flag the post as indexed so we don't try to index it again
CREATE FUNCTION procs.idx_ack_post(post_id JSON) RETURNS JSON AS $$
  sql = '''
  UPDATE posts SET index_dirty='f' WHERE id=$1
  '''
  plv8.execute sql, [post_id]
  return true
$$ LANGUAGE plls IMMUTABLE STRICT;
--}}}
-- {{{ Private Conversations 

-- #''' getting around quoting bug

CREATE FUNCTION procs.conversation_create(users JSON, message JSON) RETURNS JSON AS $$
  sql = 'INSERT INTO conversations DEFAULT VALUES RETURNING *'
  [c] = plv8.execute sql, []
  if not c
    return null
  add-participants = plv8.find_function \procs.conversation_add_participants
  add-message      = plv8.find_function \procs.conversation_add_message
  c.participants   = add-participants c.id, users
  c.messages       = [ add-message c.id, message ]
  return c
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.conversation_add_participants(cid JSON, users JSON) RETURNS JSON AS $$
  sql = 'INSERT INTO users_conversations (user_id, conversation_id) VALUES ($1, $2)'
  results = [ plv8.execute sql, [u.id, cid] for u in users ]
  # TODO - I really want to only return the users I was able to successfully add.
  return users
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.conversation_add_message(cid JSON, message JSON) RETURNS JSON AS $$
  sql = 'INSERT INTO messages (user_id, conversation_id, body) VALUES ($1, $2, $3) RETURNING *'
  [c] = plv8.execute sql, [message.user_id, cid, message.body]
  if not c
    return null
  else
    # TODO - add tags
  return c
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.conversation_by_cid(cid JSON, page JSON) RETURNS JSON AS $$
  sql = 'SELECT * FROM conversations WHERE id = $1'
  [c] = plv8.execute sql, [cid]
  if not c
    return null
  else
    messages-by-cid = plv8.find_function \procs.messages_by_cid
    messages = messages-by-cid cid, page
    c.messages = messages
  return c
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.conversations_by_user(u JSON, page JSON) RETURNS JSON AS $$
  # TODO - pagination
  sql = '''
  SELECT c.*
  FROM conversations c
  LEFT JOIN users_conversations uc ON uc.conversation_id = c.id
  LEFT JOIN users u ON u.id = uc.user_id
  WHERE u.id = $1
  ORDER BY id DESC
  '''
  conversations = plv8.execute sql, [u.id]
  # TODO order by date of last message in conversation instead of id
  return conversations
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.messages_by_cid(cid JSON, page JSON) RETURNS JSON AS $$
  # TODO - pagination
  sql = 'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY id'
  messages = plv8.execute sql, [cid]
  return messages
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION procs.domain_by_name_exists(name JSON) RETURNS JSON AS $$
  return !!plv8.execute("SELECT TRUE FROM domains WHERE name=$1 LIMIT 1", [name]).0
$$ LANGUAGE plls IMMUTABLE STRICT;

--}}}
-- vim:fdm=marker
