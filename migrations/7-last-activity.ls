
@up = (pg, cb) ->
  pg.query 'ALTER TABLE aliases ADD COLUMN last_activity timestamp', [], cb
