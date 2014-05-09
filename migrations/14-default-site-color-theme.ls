require! {
  \async
}

@up = (pg, cb) ->
  err, r <- pg.query "SELECT id FROM sites", []
  if err then return cb err

  add-default-color-theme = (s, cb) ->
    db.sites.save-color-theme { s.id, config: { color-theme: {} } }, cb

  async.each r.rows, add-default-color-theme, cb


