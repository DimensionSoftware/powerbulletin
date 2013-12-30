
@up = (pg, cb) ->
  sql = '''
  ALTER TABLE messages ADD html text DEFAULT ''
  '''
  pg.query sql, [], cb



