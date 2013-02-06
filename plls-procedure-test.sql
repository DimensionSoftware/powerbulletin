CREATE OR REPLACE FUNCTION test() RETURNS SETOF int AS
$$
# test
mylist =
  * 1
  * 2
  * 3
  * 4
  * 5

return mylist
$$
LANGUAGE plls;
