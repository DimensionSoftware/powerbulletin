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
    res.render \add-post
  new     : null
  create  : (req, res, next) ->
    db = pg.procs
    post = req.body
    post.user_id  = 1 # XXX/FIXME: in the future, this needs to be calculated from a cookie / session
    post.forum_id = 1 # XXX/FIXME: in the future, this should be passed in
    err, ap-res <- db.add-post post
    if err then return next err
    res.json ap-res
  show    : null
  edit    : null
  update  : null
  destroy : null
