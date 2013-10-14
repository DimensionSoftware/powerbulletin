require! express
require! \../component/SalesRouter
require! {
  cors
  \express-validator
  csu: \./css-urls
  jsu: \./js-urls
  mw: \./middleware
  \./pb-handlers
  \./auth-handlers
  \./auth
  \./menu
  sh: \./server-helpers
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

# authorization for dreamcodez' blitz.io account
s-app.get \/mu-d81b9b5a-572eee60-bc2ce3f6-e3fc404b (req, res) -> res.send \42

s-app.get '/dynamic/css/:file' pb-handlers.stylus

s-app.use SalesRouter.middleware

s-app.get '/ajax/check-domain-availability', (req, res, next) ->
  domain = req.query.domain
  err, domain-exists <- db.domain-by-name-exists domain
  if err then return next err
  sh.caching-strategies.nocache res
  res.json {available: !domain-exists}

s-app.post '/ajax/can-has-site-plz', sales-personal-mw, (req, res, next) ->
  user = req.user
  site = req.body
  site.user_id = user.id if user and site
  console.log {site}
  err, result <- db.create-site site
  if err then return next err
  console.log result

  err, old-menu <- db.menu result.site_id
  if err then return next err
  err, new-site <- db.site-by-id result.site_id
  new-site.config.menu = menu.upconvert old-menu
  console.warn new-site.config.menu
  err <- db.site-update new-site
  if err then return next err

  done = -> res.json result
  if result.user_id
    alias =
      user_id : user.id
      site_id : result.site_id
      name    : user.name
      rights  : { super : 1 }
      photo   : \/images/profile.jpg
    err <- db.alias-create-preverified alias
    if err then return next err
    done!
  else
    done!

# /auth/*
auth-handlers.apply-to s-app, sales-personal-mw

# The ability to give out login tokens is not applied by default.
s-app.get '/auth/once', sales-personal-mw, auth-handlers.once-setup

module.exports = s-app
