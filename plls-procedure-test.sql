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
