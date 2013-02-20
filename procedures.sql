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
  require! <[u validations]>
  errors = validations.post(post)
  if !errors.length
    if site-id = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [post.forum_id])[0]?.site_id
      sql = '''
      INSERT INTO posts (thread_id, user_id, forum_id, parent_id, title, body)
      VALUES (-1, $1, $2, $3, $4, $5)
      RETURNING id
      '''
      sql2 = 'UPDATE posts SET thread_id=$1, slug=$2 WHERE id=$3'

      params =
        * post.user_id
        * post.forum_id
        * post.parent_id
        * post.title
        * post.body

      id = plv8.execute(sql, params)[0].id

      # in the future thread_id may be harder to calculate...
      # because of nested posts...
      thread-id = id
      slug = u.title2slug(post.title, id)
      plv8.execute sql2, [thread-id, slug, id]

      u.build-forum-doc(site-id, post.forum_id)
      u.build-homepage-doc(site-id)
    else
      errors.push "forum_id invalid: #{post.forum_id}"

  return {success: !errors.length, errors, id}
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS sub_posts_tree(id JSON);
CREATE FUNCTION sub_posts_tree(id JSON) RETURNS JSON AS $$
  require! <[u validations]>
  return u.sub-posts-tree id
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON);
CREATE FUNCTION find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON) RETURNS JSON AS $$
  thing = plv8.execute(sel, sel_params)
  return thing[0] if thing.length > 0
  plv8.execute(ins, ins_params)
  plv8.elog(WARNING, ins)
  return plv8.execute(sel, sel_params)[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS find_or_create_user(usr JSON);
CREATE FUNCTION find_or_create_user(usr JSON) RETURNS JSON AS $$
  site-id = 1
  sel = '''
  SELECT u.*, a.* FROM users u JOIN aliases a ON a.user_id = u.id WHERE a.name=$1 AND a.site_id=$2;
  '''
  sel-params =
    * usr.name
    * site-id
  ins = '''
  WITH u AS (
    INSERT INTO users DEFAULT VALUES RETURNING id)
  INSERT INTO aliases (user_id, site_id, name)
  SELECT u.id, $1::int, $2::varchar FROM u;
  '''
  ins-params =
    * site-id
    * usr.name
  find-or-create = plv8.find_function('find_or_create')
  return find-or-create(sel, sel-params, ins, ins-params)
$$ LANGUAGE plls IMMUTABLE STRICT;

-- @param Object usr
--   @param String  name       user name
--   @param Integer site_id    site id
-- @returns Object user        user with all auth objects
DROP FUNCTION IF EXISTS usr(usr JSON);
CREATE FUNCTION usr(usr JSON) RETURNS JSON AS $$
  sql = """
  SELECT u.id, a.name, a.site_id, auths.type, auths.json 
  FROM users u
  JOIN aliases a ON a.user_id = u.id
  LEFT JOIN auths ON auths.user_id = u.id
  WHERE a.name = $1
  AND a.site_id = $2
  """
  auths = plv8.execute(sql, [ usr.name, usr.site_id ])
  make-user = (memo, auth) ->
    memo.id = auth.id
    memo.site_id = auth.id
    memo.name = auth.name
    memo.auths[auth.type] = JSON.parse(auth.json)
    memo
  return auths.reduce make-user, { auths: {} }
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

DROP FUNCTION IF EXISTS forum_doc_by_type_and_slug(site_id JSON, type JSON, slug JSON);
CREATE FUNCTION forum_doc_by_type_and_slug(site_id JSON, type JSON, slug JSON) RETURNS JSON AS $$
  require! <[u]>
  res = plv8.execute('SELECT id FROM forums WHERE site_id=$1 AND slug=$2', [site_id, slug])
  if id  = res[0]?.id
    return u.doc site_id, "forum_#{type}", id
  else
    return null
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS build_all_docs(site_id JSON);
CREATE FUNCTION build_all_docs(site_id JSON) RETURNS JSON AS $$
  require! <[u]>

  u.build-homepage-doc(site_id)

  for f in plv8.execute('SELECT id FROM forums WHERE site_id=$1', [site_id])
    u.build-forum-doc(site_id, f.id)

  return true
$$ LANGUAGE plls IMMUTABLE STRICT;
