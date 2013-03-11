require! {
  \mutant
  \cssmin
  './mutants'
  './resources'
  './handlers'
  mmw: 'mutant/middleware'
  mw: './middleware',
  pg: './postgres'
}
global <<< require './helpers' # pull helpers (common) into global (play nice :)

# <API RESOURCES>
# ---------
app.resource 'resources/posts',  resources.post

app.post '/resources/posts/:id/impression', handlers.add-impression
app.post '/resources/posts/:id/censor', handlers.censor

# <PAGE HANDLERS & MISC.>
# ---------
common-js = [
  "#{cvars.cache3_url}/local/jquery.masonry.min.js",
  "#{cvars.cache2_url}/local/jquery.cookie-1.3.1.min.js",
  "#{cvars.cache2_url}/local/waypoints.min.js",
  "#{cvars.cache2_url}/local/waypoints-sticky.min.js",
  "#{cvars.cache5_url}/local/history.min.js",
  "#{cvars.cache5_url}/local/history.adapter.native.min.js",
  "#{cvars.cache3_url}/fancybox/jquery.fancybox.pack.js",
  "#{cvars.cache3_url}/local/jquery.transit-0.9.9.min.js",
  "#{cvars.cache3_url}/local/infinity.min.js",
  "#{cvars.cache4_url}/powerbulletin#{if process.env.NODE_ENV is \production then '.min' else ''}.js"]
common-css = [
  "#{cvars.cache2_url}/fancybox/jquery.fancybox.css",
  '/dynamic/css/theme.styl,layout.styl']

app.get '/hello' handlers.hello

# local auth
app.post '/auth/login'           handlers.login
app.post '/auth/register'        handlers.register
app.post '/auth/choose-username' handlers.choose-username

app.get  '/auth/facebook'        handlers.login-facebook
app.get  '/auth/facebook/return' handlers.login-facebook-return
app.get  '/auth/facebook/finish' handlers.login-facebook-finish

app.get  '/auth/google'          handlers.login-google
app.get  '/auth/google/return'   handlers.login-google-return
app.get  '/auth/google/finish'   handlers.login-google-finish

app.get  '/auth/twitter'         handlers.login-twitter
app.get  '/auth/twitter/return'  handlers.login-twitter-return
app.get  '/auth/twitter/finish'  handlers.login-twitter-finish

app.get  '/auth/logout'   handlers.logout
# UI SKETCH UP:
#
# Connect to a social network:
# Facebook, Twitter
# OR
# Register @ <Forum Name>.com
# # post endpoint
app.post '/auth/register', handlers.register
# todo html for use in fancybox or modal dialog at get route

# json response with user info
app.get '/auth/user', handlers.user

app.get '/',
  mw.geo,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.homepage

# dynamic serving
app.get '/dynamic/css/:file' handlers.stylus

app.get '/favicon.ico', (req, res, next) ->
  # replace with real favicon
  next 404, \404

app.get '/:forum/most-active',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

if process.env.NODE_ENV != 'production'
  app.get '/debug/docs/:type/:key', (req, res, next) ->
    db = pg.procs
    err, d <- db.doc res.locals.site.id, req.params.type, req.params.key
    if err then return next(err)
    res.json d

  app.get '/debug/sub-posts-tree/:post_id', (req, res, next) ->
    db = pg.procs
    err, d <- db.sub-posts-tree req.params.post_id
    if err then return next(err)
    res.json d


# forum + post
app.all new RegExp('/(.+)/t/(.+)'),
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

# bare forum (catch all)
app.all new RegExp('/(.+)'),
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.forum
