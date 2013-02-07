-- CLEANUP
DROP FUNCTION IF EXISTS test();
DROP FUNCTION IF EXISTS get_user(BIGINT);
DROP FUNCTION IF EXISTS get_doc(TEXT, TEXT);

-- FUNCTION: test
CREATE OR REPLACE FUNCTION test() RETURNS JSON AS $$
  return require(\mymod).foo!

$$ LANGUAGE plls IMMUTABLE STRICT;

-- FUNCTION: get_user
CREATE FUNCTION get_user(id BIGINT) RETURNS TABLE (id BIGINT, created TIMESTAMP, updated TIMESTAMP) AS $$
  return plv8.execute('SELECT * FROM users WHERE id=$1', [id])
$$ LANGUAGE plls IMMUTABLE STRICT;

-- FUNCTION: get_doc
CREATE FUNCTION get_doc(type TEXT, key TEXT) RETURNS JSON AS $$
  return plv8.execute('SELECT json FROM docs WHERE type=$1 AND key=$2', [type, key])[0]

CREATE FUNCTION put_doc
$$ LANGUAGE plls IMMUTABLE STRICT;
