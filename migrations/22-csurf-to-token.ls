
@up = (pg, cb) ->
  # csurf -> token + unique (used to lookup when user saves their draft as a real post)
  sql = '''
    ALTER TABLE attachments RENAME COLUMN csurf TO token;
    ALTER TABLE attachments ADD UNIQUE (token);
  '''
  err, r <- pg.query sql, [], cb
  if err then return cb err
