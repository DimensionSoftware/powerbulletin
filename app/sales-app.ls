require! express
require! \../component/SalesRouter
require! {
  cors
  async
  \express-validator
  \connect
  \body-parser
  \cookie-parser
  \cookie-session
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
s-app.use connect.logger(immediate: false, format: sh.dev-log-format) if (env is \development or env is void)

# middleware for auth routes
sales-personal-mw =
  * cors(origin: true, credentials: true)
  * body-parser.urlencoded!
  * cookie-parser!
  * cookie-session {secret:cvars.secret, proxy:true, cookie:{proxy:true, secure:true, max-age:1000*60*60*24*365}}
  * auth.mw.initialize
  * auth.mw.session

# authorization for dreamcodez' blitz.io account
s-app.get \/mu-d81b9b5a-572eee60-bc2ce3f6-e3fc404b (req, res) -> res.send \42

s-app.get '/dynamic/css/:file' pb-handlers.stylus

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
  if site.domain.match /^\s*\./
    return res.json success: false, errors: ["Invalid domain."]

  err, result <- db.create-site site
  if err then return next err
  console.warn \create-site, err, result

  err, old-menu <- db.menu result.site_id
  if err then return next err
  err, new-site <- db.site-by-id result.site_id
  if err then return next err
  unless new-site then return res.json success:false, errors:['Site exists!'] # guard
  new-site.config?menu = menu.upconvert old-menu
  new-site.config.posts-per-page = 20
  new-site.config.items-per-page = 20
  new-site.config.header = \powerbulletin_header.jpg # default pb header
  console.warn new-site.config?menu
  err <- db.site-update new-site
  if err then return next err

  # generate master.css & color
  err <- db.sites.save-color-theme { new-site.id, config: { color-theme: {} } }
  if err then return next err
  err <- sh.render-css-to-file new-site.id, \master.styl
  if err then return next err

  done = -> res.json result
  if result.user_id
    alias =
      user_id : user.id
      site_id : result.site_id
      name    : user.name
      rights  : { super : 1 }
      photo   : \/images/profile.png
    err <- db.alias-create-preverified alias
    if err then return next err
    done!
  else
    done!

s-app.get '/ajax/sites-and-memberships', sales-personal-mw, (req, res, next) ->
  sh.caching-strategies.nocache res
  if not req.user then return res.json success: false, errors: [ "No user" ]
  tasks =
    sites:       db.sites.owned-by-user req.user.id, _
    memberships: db.sites.user-is-member-of req.user.id, _
  err, r <- async.auto tasks
  if err then return res.json success: false, errors: [ err ]
  {sites, memberships} = r
  best    = []
  grouped = memberships
    |> filter (m) -> # remove memberships we own
      !find ((s) -> m.site_id is s.id), sites
    #|> filter (m) -> # remove powerbulletin.com membership (leaving community.)
    #  !m.site_id is 1
    |> group-by (.site_id)

  # remove PB domains where possible
  for k of grouped
    domains = grouped[k]
    if domains.length is 1 # single domain for site, so use it
      best.push domains.0
    else
      # only push custom domains
      [pb, custom] = partition (.domain.match /(powerbulletin\.com)|(pb\.com)/), domains
      if custom.length
        best.push custom # all custom domains
      else
        best.push(pb |> find (.domain.match if process.env.NODE_ENV is \production then /powerbulletin.com$/ else /pb.com$/))
  res.json {success:true, sites, memberships:Obj.values best}

# /auth/*
auth-handlers.apply-to s-app, sales-personal-mw

# The ability to give out login tokens is not applied by default.
s-app.get '/auth/once', sales-personal-mw, auth-handlers.once-setup

# assume SalesRouter needs this middleware
sales-personal-mw.for-each ((m) -> s-app.use m)
s-app.use SalesRouter.middleware

module.exports = s-app
