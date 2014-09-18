
@up = (pg, cb) ->
  # null post_id means attachment's post never saved (orphaned) and can be cleaned up after some time
  sql = 'ALTER TABLE attachments ALTER COLUMN post_id DROP NOT NULL;'
  err, r <- pg.query sql, [], cb
  if err then return cb err
