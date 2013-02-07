-- CLEANUP

-- FUNCTIONS
DROP FUNCTION IF EXISTS test();
CREATE OR REPLACE FUNCTION test() RETURNS JSON AS $$
  return require(\mymod).foo!
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS get_user(BIGINT);
CREATE FUNCTION get_user(id BIGINT) RETURNS TABLE (id BIGINT, created TIMESTAMP, updated TIMESTAMP) AS $$
  return plv8.execute('SELECT * FROM users WHERE id=$1', [id])
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS get_doc(TEXT, TEXT);
CREATE FUNCTION get_doc(type TEXT, key TEXT) RETURNS JSON AS $$
  return plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', [type, key])[0]
$$ LANGUAGE plls IMMUTABLE STRICT;

DROP FUNCTION IF EXISTS add_post(JSON);
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

  return {success, errors, id, forums}
$$ LANGUAGE plls IMMUTABLE STRICT;
--CREATE FUNCTION put_doc(
--$$ LANGUAGE plls IMMUTABLE STRICT;
