require! {
  pg: './postgres'
}


@users =
  create : (req, res) ->
    user = req.params.user
    # munge data
    (err, user) <- db.find-or-create user
    res.json user

@post =
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
    res.json ap-res
  show    : null
  edit    : null
  update  : null
  destroy : null
