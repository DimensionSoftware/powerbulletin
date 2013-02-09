require! {
  passport
  pg: './postgres'
}

db = pg.procs

Strategy = require('passport-local').Strategy

passport.use(new Strategy (user, password, cb) ->
  sel = """
  SELECT u.*, a.* FROM user u JOIN aliases a ON a.user_id = u.id WHERE a.name=$1 AND a.site_id=$2;
  """
  ins = """
  BEGIN;
  INSERT INTO user (updated) VALUES (NOW()) RETURNING id;
  COMMIT;
  """
  db.find_or_create sel sel-params ins ins-params
  cb null user
  )

@users =
  create : (req, res) ->
    user = req.params.user
    # munge data
    (err, user) <- db.find_or_create user
    res.json user

@post =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.render \add-post
  new     : null
  create  : (req, res, next) ->
    post = req.body
    post.user_id  = 1 # XXX/FIXME: in the future, this needs to be calculated from a cookie / session
    post.forum_id = 1 # XXX/FIXME: in the future, this should be passed in
    err, ap-res <- db.add_post JSON.stringify(post)
    if err then return next err
    res.json ap-res
  show    : null
  edit    : null
  update  : null
  destroy : null
