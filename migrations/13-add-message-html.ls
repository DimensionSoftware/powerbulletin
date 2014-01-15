require! {
  \async
  \../app/format
}

@up = (pg, cb) ->
  sql = '''
  ALTER TABLE messages ADD html text DEFAULT ''
  '''
  err, r <- pg.query sql, []
  if err then return cb err

  err, r <- pg.query """SELECT * FROM messages WHERE html = ''""", []
  if err then return cb err

  add-html-to-messages = (m, cb) ->
    pg.query "UPDATE messages SET html = $1 WHERE id = $2", [format.render(m.body), m.id], cb

  async.each r.rows, add-html-to-messages, cb

