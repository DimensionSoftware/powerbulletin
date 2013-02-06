-- FUNCTION: test
DROP FUNCTION IF EXISTS test();
CREATE OR REPLACE FUNCTION test() RETURNS SETOF int AS $$
  # test
  mylist =
    * 1
    * 2
    * 3
    * 4
    * 5

  mylist2 = require(\mymod).foo!

  return mylist2
$$ LANGUAGE plls IMMUTABLE STRICT;

-- FUNCTION: get_user
DROP FUNCTION IF EXISTS get_user(int);
DROP TYPE IF EXISTS get_user_r;
CREATE TYPE get_user_r AS
  ( id bigint
  , created timestamp
  , updated timestamp);
CREATE FUNCTION get_user(id int) RETURNS SETOF get_user_r AS $$
  return plv8.execute('SELECT * FROM USERS WHERE id=$1', [id])
$$ LANGUAGE plls IMMUTABLE STRICT;
