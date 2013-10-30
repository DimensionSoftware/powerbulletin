
@up = (pg, cb) ->
  sql = '''
    COMMENT ON COLUMN users.email IS 'local auth email';
  '''
  pg.query sql, [], cb
