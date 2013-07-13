require! express
require! \../component/SalesLoader
require! {
  cors
  \express-validator
  csu: \./css-urls
  jsu: \./js-urls
  mw: \./middleware
  \./pb-handlers
  \./auth-handlers
  \./auth
}

# would like to just call it app, but global 'app' is reserved
s-app = express!
s-app.enable 'json callback'
s-app.enable 'trust proxy' # parse x-forwarded-for in req.ip, etc...

# middleware for the whole app
sales-mw =
  * mw.vars
  * mw.cvars
  * mw.multi-domain
  * express-validator
sales-mw.for-each ((m) -> s-app.use m)

# middleware for auth routes
sales-personal-mw =
  * cors(origin: true, credentials: true)
  * express.body-parser!
  * express.cookie-parser!
  * express.cookie-session {secret:cvars.secret}
  * auth.mw.initialize
  * auth.mw.session

s-app.get '/dynamic/css/:file' pb-handlers.stylus

s-app.get '/' (req, res, next) ->
  scripts =
    * jsu.jquery
    * jsu.jquery-cookie
    * jsu.jquery-history
    * jsu.jquery-history-native
    * jsu.jquery-nicescroll
    * jsu.jquery-ui
    * jsu.raf
    * jsu.powerbulletin-sales

  stylesheets = [
    csu.master-sales
  ]

  locals = {scripts, stylesheets} <<< cvars
  sl = new SalesLoader {locals}
  res.content-type \html
  res.send sl.html(false)

s-app.get '/ajax/check-domain-availability', (req, res, next) ->
  domain = req.query.domain
  err, domain-exists <- db.domain-by-name-exists domain
  if err then return next err
  res.json {available: !domain-exists}

s-app.post '/ajax/can-has-site-plz', sales-personal-mw, (req, res, next) ->
  user = req.user
  site = req.body
  site.user_id = user.id if user and site
  console.log {site}
  err, result <- db.create-site site
  if err then return next err
  console.log result

  done = -> res.json result
  if result.user_id
    alias =
      user_id : user.id
      site_id : result.site_id
      name    : user.name
      rights  : { super : 1 }
    <- db.alias-create-preverified alias
    done!
  else
    done!

# /auth/*
auth-handlers.apply-to s-app, sales-personal-mw

# The ability to give out login tokens is not applied by default.
s-app.get '/auth/once', sales-personal-mw, auth-handlers.once-setup

module.exports = s-app
