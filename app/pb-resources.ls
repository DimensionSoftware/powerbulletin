require! {
  pg: \./postgres
  c: \./cache
  h: \./helpers
  sioa: \socket.io-announce
}

announce = sioa.create-client!

@site =
  update: (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    return # FIXME needs to remove keys from blank input & merge current config before saving 
    # save site
    console.log req.params
    site =
      name:    ''
      id:      req.user.site_id
      user_id: req.user.id
      config: {
        facebook-client-id:      req.params.facebook-client-id
        facebook-client-secret:  req.params.facebook-client-secret
        twitter-consumer-key:    req.params.twitter-consumer-key
        twitter-consumer-secret: req.params.twitter-consumer-secret
        google-consumer-key:     req.params.google-consumer-key
        google-consumer-secret:  req.params.google-consumer-secret}

    console.log site
    err, r <- db.site-update site
    if err then return next err
    res.json r
@users =
  create : (req, res) ->
    if not req?user?rights?super then return next 404 # guard
    user = req.params.user
    # munge data
    (err, user) <- db.find-or-create user
    res.json user
@posts =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.locals.pid = req.query.pid
    res.render \post-new
  new     : null
  create  : (req, res, next) ->
    return next(404) unless req.user
    db           = pg.procs
    post         = req.body
    post.user_id = req.user.id
    post.html    = h.html post.body
    post.ip      = res.vars.remote-ip
    post.tags    = h.hash-tags post.body
    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      post.id = ap-res.id
      c.invalidate-post post.id # blow cache!

    unless post.parent_id
      err, new-post <- db.post post.id
      announce.emit \thread-create new-post
    else
      err, new-post <- db.post post.id
      new-post.posts = []
      announce.emit \post-create new-post

    res.json ap-res
  show    : (req, res, next) ->
    db = pg.procs
    if post-id = parse-int(req.params.post)
      err, post <- db.post post-id
      if err then return next err
      res.json post
    else
      return next 404
  edit    : null
  update  : (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    # TODO is_owner req?user
    # TODO secure & csrf
    # save post
    req.body.user_id = req.user.id
    req.body.html = h.html req.body.body
    post = req.body
    err, r <- db.edit-post(req.user, post)
    if err then return next err

    if r.success
      # blow cache !
      c.invalidate-post post.id

    res.json r
  destroy : (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    # TODO currently only super users can censor.  how about post owners?
    db = pg.procs

    if post-id = parse-int(req.params.post)
      # we don't really destroy, we just archive
      err <- db.archive-post(post-id)
      if err then return next err
      res.json {success: true}
    else
      next 404

# vim:fdm=indent
