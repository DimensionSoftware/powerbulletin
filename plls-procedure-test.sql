CREATE FUNCTION get_doc(type JSON, key JSON) RETURNS JSON AS $$
  return require(\u).get-doc type, key
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION put_doc(type JSON, key JSON, val JSON) RETURNS JSON AS $$
  return require(\u).put-doc type, key, JSON.stringify(val)
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION add_post(post JSON) RETURNS JSON AS $$
  require! <[u validations]>
  errors = validations.post(post)
  success = !errors.length
  if success
    sql = '''
      INSERT INTO posts (user_id, forum_id, title, body)
      VALUES ($1, $2, $3, $4)
      RETURNING id
      '''
    params =
      * post.user_id
      * post.forum_id
      * post.title
      * post.body

    id = plv8.execute(sql, params)[0].id
    # only works for forum-id 1 right now
    forums = u.forums 1
    u.put-doc \misc, \homepage, JSON.stringify({forums})

  return {success, errors, id}
$$ LANGUAGE plls IMMUTABLE STRICT;


CREATE FUNCTION find_or_create(sel JSON, sel_params JSON, ins JSON, ins_params JSON) RETURNS JSON AS $$
  thing = plv8.execute(sel, sel_params)
  return thing[0] if thing.length > 0
  plv8.execute(ins, ins_params)
  plv8.elog(WARNING, ins)
  return plv8.execute(sel, sel_params)[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

CREATE FUNCTION find_or_create_user(usr JSON) RETURNS JSON AS $$
  site-id = 1
  sel = """
  SELECT u.*, a.* FROM users u JOIN aliases a ON a.user_id = u.id WHERE a.name=$1 AND a.site_id=$2;
  """
  sel-params =
    * usr.name
    * site-id
  ins = """
  WITH u AS (
    INSERT INTO users DEFAULT VALUES RETURNING id)
  INSERT INTO aliases (user_id, site_id, name)
    SELECT u.id, $1::int, $2::varchar FROM u;
  """
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
CREATE FUNCTION find_user(usr JSON) RETURNS JSON AS $$
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
CREATE FUNCTION find_site_by_domain(site JSON) RETURNS JSON AS $$
  sql = """
  SELECT * FROM sites WHERE domain = $1
  """
  s = plv8.execute(sql, [ site.domain ])
  return s[0]
$$ LANGUAGE plls IMMUTABLE STRICT;
