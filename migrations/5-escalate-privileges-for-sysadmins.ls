
@up = (pg, cb) ->
  sql = '''
    UPDATE users SET rights='{"super":1}' WHERE id IN (1,2,3);
  '''
  pg.query sql, [], cb
