require! {
  pg: './postgres',
  c: './cache'
}


@users =
  create : (req, res) ->
    user = req.params.user
    # munge data
    (err, user) <- db.find-or-create user
    res.json user

@posts =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.locals.pid = req.query.pid
    res.render \add-post
  new     : null
  create  : (req, res, next) ->
    return next(404) unless req.user
    db = pg.procs
    post = req.body
    post.user_id = req.user.id
    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      c.invalidate-forum post.forum_id, console.warn

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
    return next(404) unless req.user # or authorized_as \admin
    # TODO secure csrf, etc...
    # save post
    req.body.user_id = req.user.id
    err, r <- db.edit-post(req.body)
    if err then return next err
    res.json r
  destroy : (req, res, next) ->
    return next(404) unless req.user
    db = pg.procs

    if post-id = parse-int(req.params.post)
      # we don't really destroy, we just archive
      err <- db.archive-post(post-id)
      if err then return next err
      res.json {success: true}
    else
      next 404
