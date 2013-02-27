require! {
  async
  pg : './postgres'
  v  : './varnish'
}

export invalidate-forum = (forum-id, cb = (->)) ->
  db = pg.procs
  err, bans <- db.ban-patterns-for-forum forum-id
  if err then return cb(err)
  async.map-series bans, (-> v.ban-url(...arguments)), cb
