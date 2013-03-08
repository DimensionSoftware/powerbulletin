DROP FUNCTION IF EXISTS doc(site_id JSON, type JSON, key JSON);
CREATE FUNCTION doc(site_id JSON, type JSON, key JSON) RETURNS JSON AS $$
  return require(\u).doc site_id, type, key
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS put_doc(site_id JSON, type JSON, key JSON, val JSON);
CREATE FUNCTION put_doc(site_id JSON, type JSON, key JSON, val JSON) RETURNS JSON AS $$
  return require(\u).put-doc site_id, type, key, val
$$ LANGUAGE plls IMMUTABLE STRICT;

-- THIS IS ONLY FOR TOPLEVEL POSTS
-- TODO: needs to support nested posts also, and update correct thread-id
DROP FUNCTION IF EXISTS add_post(post JSON);
CREATE FUNCTION add_post(post JSON) RETURNS JSON AS $$
  var uri
  require! <[u validations]>
  errors = validations.post(post)
  if !errors.length
    if site-id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [post.forum_id])[0]?.site_id
      [{nextval}] = plv8.execute("SELECT nextval('posts_id_seq')", [])

      forum-id = parse-int(post.forum_id) or null
      parent-id = parse-int(post.parent_id) or null
      if post.parent_id
        [{thread_id}] = plv8.execute('SELECT thread_id FROM posts WHERE id=$1', [post.parent_id])
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
      INSERT INTO posts (id, thread_id, user_id, forum_id, parent_id, title, slug, body)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      '''

      params =
        * nextval
        * thread_id
        * parse-int(post.user_id) or null
        * forum-id
        * parent-id
        * post.title
        * slug
        * post.body

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

    else
      errors.push "forum_id invalid: #{post.forum_id}"

  return {success: !errors.length, errors, id: nextval, uri}
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS archive_post(post_id JSON);
CREATE FUNCTION archive_post(post_id JSON) RETURNS JSON AS $$
  require! u
  [{forum_id}] = plv8.execute "SELECT forum_id FROM posts WHERE id=$1", [post_id]
  [{site_id}] = plv8.execute 'SELECT site_id FROM forums WHERE forum_id=$1', [forum_id]
  plv8.execute "UPDATE posts SET archived='t' WHERE id=$1", [post_id]
  return true
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS sub_posts_tree(post_id JSON);
CREATE FUNCTION sub_posts_tree(post_id JSON) RETURNS JSON AS $$
  require! u
  return u.sub-posts-tree post_id
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON);
CREATE FUNCTION find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON) RETURNS JSON AS $$
  thing = plv8.execute(sel, sel_params)
  return thing[0] if thing.length > 0
  plv8.elog(WARNING, "-- INSERT --")
  plv8.elog(WARNING, ins, ins_params)
  plv8.execute(ins, ins_params)
  return plv8.execute(sel, sel_params)[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

-- Find a user by auths.type and auths.id
-- However, more information should be provided in case a new user needs to be created.
-- @param Object usr
--   @param String type         auths.type (facebook|google|twitter|local)
--   @param Number id           auths.id (3rd party user id)
--   @param JSON   profile      auths.profile (3rd party profile object)
--   @param Number site_id      aliases.site_id
--   @param String name         aliases.name
DROP FUNCTION IF EXISTS find_or_create_user(usr JSON);
CREATE FUNCTION find_or_create_user(usr JSON) RETURNS JSON AS $$
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
        SELECT $1::bigint, u.id, $2::varchar, $3::json FROM u
        RETURNING *
    )
  INSERT INTO aliases (user_id, site_id, name)
    SELECT u.id, $4::bigint, $5::varchar FROM u;
  '''
  ins-params =
    * usr.id
    * usr.type
    * JSON.stringify(usr.profile)
    * usr.site_id
    * usr.name

  find-or-create = plv8.find_function('find_or_create')
  return find-or-create(sel, sel-params, ins, ins-params)
$$ LANGUAGE plls IMMUTABLE STRICT;

-- change alias
DROP FUNCTION IF EXISTS change_alias(usr JSON);
CREATE FUNCTION change_alias(usr JSON) RETURNS JSON AS $$
  sql = '''
  UPDATE aliases SET name = $1 WHERE user_id = $2 AND site_id = $3
    RETURNING *
  '''
  return plv8.execute(sql, [usr.name, usr.user_id, usr.site_id])
$$ LANGUAGE plls IMMUTABLE STRICT;

-- @param Object usr
--   @param String  name       user name
--   @param Integer site_id    site id
-- @returns Object user        user with all auth objects
DROP FUNCTION IF EXISTS usr(usr JSON);
CREATE FUNCTION usr(usr JSON) RETURNS JSON AS $$
  sql = """
  SELECT u.id, u.rights, a.name, a.site_id, auths.type, auths.profile 
  FROM users u
  JOIN aliases a ON a.user_id = u.id
  LEFT JOIN auths ON auths.user_id = u.id
  WHERE a.name = $1
  AND a.site_id = $2
  """
  auths = plv8.execute(sql, [ usr.name, usr.site_id ])
  make-user = (memo, auth) ->
    memo.id = auth.id
    memo.site_id = auth.site_id
    memo.name = auth.name
    memo.auths[auth.type] = auth.profile
    memo
  user = auths.reduce make-user, { auths: {} }
  user.rights = auths[0].rights
  return user
$$ LANGUAGE plls IMMUTABLE STRICT;

-- @param Object site
--   @param String domain      domain of site
DROP FUNCTION IF EXISTS site_by_domain(site JSON);
CREATE FUNCTION site_by_domain(site JSON) RETURNS JSON AS $$
  sql = """
  SELECT * FROM sites WHERE domain = $1
  """
  s = plv8.execute(sql, [ site.domain ])
  return s[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS domains();
CREATE FUNCTION domains() RETURNS JSON AS $$
  sql = """
  SELECT domain FROM sites
  """
  return plv8.execute(sql).map (d) -> d.domain
$$ LANGUAGE plls IMMUTABLE STRICT;

-- XXX sort is used but will need to be reworked for geospatial
DROP FUNCTION IF EXISTS forum_doc(site_id JSON, sort JSON, uri JSON);
CREATE FUNCTION forum_doc(site_id JSON, sort JSON, uri JSON) RETURNS JSON AS $$
  require! u
  res = plv8.execute('SELECT id FROM forums WHERE site_id=$1 AND uri=$2', [site_id, uri])
  if forum-id = res[0]?.id
    doc = JSON.parse u.doc(site_id, "forum_#{sort}", forum-id)
    doc.top-threads = JSON.parse u.doc(site_id, "threads_#{sort}", forum-id)
    return doc
  else
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS add_thread_impression(thread_id JSON);
CREATE FUNCTION add_thread_impression(thread_id JSON) RETURNS JSON AS $$
  plv8.elog WARNING, thread_id
  if not thread_id or thread_id is \undefined
    return false
  plv8.elog WARNING, 'should have bailed'
  sql = '''
  UPDATE posts SET views = views + 1 WHERE id = $1 RETURNING *
  '''
  res = plv8.execute sql, [thread_id]
  if res.length
    forum-id = res[0].forum_id
    sql2 = 'SELECT site_id FROM forums WHERE id = $1'
    res2 = plv8.execute sql2, [forum-id]
    site-id = res2[0].site_id
  return res[0]?.views
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS build_all_uris(site_id JSON);
CREATE FUNCTION build_all_uris(site_id JSON) RETURNS JSON AS $$
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

DROP FUNCTION IF EXISTS ban_patterns_for_forum(forum_id JSON);
CREATE FUNCTION ban_patterns_for_forum(forum_id JSON) RETURNS JSON AS $$
  if f = plv8.execute('SELECT parent_id, uri FROM forums WHERE id=$1', [forum_id])[0]
    bans = []
    bans.push '^/$' unless f.parent_id # sub-forums need not ban the homepage.. maybe??
    bans.push "^#{f.uri}" # anything that beings with forum uri
    return bans
  else
    return []
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS menu(site_id JSON);
CREATE FUNCTION menu(site_id JSON) RETURNS JSON AS $$
  require! u
  return u.menu site_id
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS homepage_forums(forum_id JSON);
CREATE FUNCTION homepage_forums(forum_id JSON) RETURNS JSON AS $$
  require! u
  return u.homepage-forums forum_id 
$$ LANGUAGE plls IMMUTABLE STRICT;

-- XXX: this should really be called 'forum' since it represents one forum (and nested forums)
-- but until the template is updated to not be plural i'll leave it
DROP FUNCTION IF EXISTS forums(forum_id JSON);
CREATE FUNCTION forums(forum_id JSON) RETURNS JSON AS $$
  require! u
  return u.forums forum_id, \popular
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS top_threads(forum_id JSON);
CREATE FUNCTION top_threads(forum_id JSON) RETURNS JSON AS $$
  require! u
  return u.top-threads forum_id, \popular 
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS uri_to_forum_id(site_id JSON, uri JSON);
CREATE FUNCTION uri_to_forum_id(site_id JSON, uri JSON) RETURNS JSON AS $$
  require! u
  try
    [{id}] = plv8.execute 'SELECT id FROM forums WHERE site_id=$1 AND uri=$2', [site_id, uri]
    return id
  catch
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS uri_to_post(site_id JSON, uri JSON);
CREATE FUNCTION uri_to_post(site_id JSON, uri JSON) RETURNS JSON AS $$
  require! u
  try
    sql = '''
    SELECT p.*
    FROM posts p
    JOIN forums f ON p.forum_id=f.id
    WHERE f.site_id=$1 AND p.uri=$2
    '''
    [post] = plv8.execute sql, [site_id, uri]
    return post
  catch
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

-- c is for 'command'
DROP FUNCTION IF EXISTS censor(c JSON);
CREATE FUNCTION censor(c JSON) RETURNS JSON AS $$
  require! {u, validations}

  sql = '''
  INSERT INTO moderations (user_id, post_id, reason)
  VALUES ($1, $2, $3)
  '''

  errors = validations.censor(c)

  if !errors.length
    plv8.execute sql, [c.user_id, c.post_id, c.reason]

  return {success: !errors.length, errors}
$$ LANGUAGE plls IMMUTABLE STRICT;
