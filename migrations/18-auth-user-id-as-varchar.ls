number-format = '9999999999999999999999999999'

@up = (pg, cb) ->
  sql = """
  ALTER TABLE auths ALTER COLUMN id SET DATA TYPE varchar(128) USING trim(to_char(id, '#number-format'));
  """
  pg.query sql, [], cb

/*
@down = (pg, cb) ->
  sql = """
  ALTER TABLE auths ALTER COLUMN id SET DATA TYPE numeric USING to_number(id, '9999999999999999999999999999');
  """
  pg.query sql, [], cb
*/
