
@up = (pg, cb) ->
  sql = '''
  ALTER TABLE forums DROP description;
  '''
  pg.query sql, [], cb


