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
  db.find-or-create sel sel-params ins ins-params
  cb null user
  )

@users =
  create : (req, res) ->
    user = req.params.user
    # munge data
    (err, user) <- db.find-or-create user
    res.json user

@posts =
  index   : (req, res) -> console.log 'posts'
  new     : null
  create  : null
  show    : null
  edit    : null
  update  : null
  destroy : null

