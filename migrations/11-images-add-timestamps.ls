
@up = (pg, cb) ->
  sql = '''
    ALTER TABLE images ADD COLUMN created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
    ALTER TABLE images ADD COLUMN updated TIMESTAMP;
  '''
  pg.query sql, [], cb

