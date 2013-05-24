require! {
  async
  pg : './postgres'
  v  : './varnish'
}

# TODO XXX: blow homepage and forum page accordingly, not just thread and below
export invalidate-post = (post-id, user-name, cb = (->)) ->
  db = pg.procs # XXX: race condition.. ordering of when pg is initialized
  err, bans <- db.bans-for-post post-id, user-name
  if err then return cb(err)
  async.map-series bans, (-> v.ban(...arguments) ), (err) ->
    if err then return cb err
    console.log "[cache] invalidated post: #{post-id}"
    cb!
