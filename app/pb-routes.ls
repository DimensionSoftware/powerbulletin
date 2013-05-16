require! {
  cssmin
  express
  mutant
  \./auth
  \express-validator
  mmw: \mutant/middleware
  pg:  \./postgres
  mw:  \./middleware

  mutants:   \./pb-mutants
  handlers:  \./pb-handlers
  resources: \./pb-resources
}
global <<< require \./helpers # pull helpers (common) into global (play nice :)

# middleware we will use only on personalized routes to save cpu cycles!
personal-mw =
  * express-validator
  * express.body-parser!
  * express.cookie-parser!
  * express.cookie-session {secret:cvars.secret}
  * auth.mw.initialize
  * auth.mw.session

#{{{ API Resources
app.resource \resources/sites,             personal-mw, resources.sites
app.resource \resources/posts,             personal-mw, resources.posts
app.get  \/resources/posts/:id/sub-posts,  personal-mw, handlers.sub-posts
app.post \/resources/posts/:id/impression, personal-mw, handlers.add-impression
app.post \/resources/posts/:id/censor,     personal-mw, handlers.censor
app.post \/resources/users/:id/avatar,     personal-mw, handlers.profile-avatar
#}}}

# XXX Common is for all environments
common-js = [ #{{{ Common JS
  "#{cvars.cache5-url}/local/jquery-1.9.1.min.js",
  "#{cvars.cache5-url}/local/jquery-ui.min.js",
  "#{cvars.cache3-url}/local/jquery.masonry.min.js",
  "#{cvars.cache2-url}/local/jquery.cookie-1.3.1.min.js",
  "#{cvars.cache4-url}/local/jquery.sceditor.bbcode.min.js",
  "#{cvars.cache-url}/local/waypoints.min.js",
  "#{cvars.cache5-url}/local/history.min.js",
  "#{cvars.cache5-url}/local/history.adapter.native.min.js",
  "#{cvars.cache4-url}/fancybox/jquery.fancybox.pack.js",
  "#{cvars.cache3-url}/local/jquery.transit-0.9.9.min.js",
  "#{cvars.cache2-url}/local/jquery.html5uploader.js",
  "#{cvars.cache2-url}/jcrop/js/jquery.Jcrop.min.js",
  "#{cvars.cache-url}/local/reactive.js",
  "#{cvars.cache3-url}/local/jquery.nicescroll.min.js",
  "#{cvars.cache4-url}/socket.io/socket.io.js",
  "#{cvars.cache-url}/powerbulletin#{if process.env.NODE_ENV is \production then '.min' else ''}.js"]
#}}}
common-css = [ #{{{ Common CSS
  "#{cvars.cache2-url}/fancybox/jquery.fancybox.css",
  "#{cvars.cache3-url}/local/jquery.sceditor.default.min.css",
  "#{cvars.cache4-url}/jcrop/css/jquery.Jcrop.min.css",
  '/dynamic/css/master.styl']
#}}}

# inject testing code in dev only
app.configure \development ->
  entry = common-js.pop!
  common-js.push "#{cvars.cache5-url}/local/mocha.js"
  common-js.push "#{cvars.cache5-url}/local/chai.js"
  common-js.push entry

#{{{ Admin
app.get \/admin/:action?,
  personal-mw.concat(
    , mw.add-js(common-js)
    , mw.add-css(common-css)
    , mmw.mutant-layout(\layout, mutants)
  ),
  handlers.admin
#}}}
#{{{ Local auth
#
app.post '/auth/login',           personal-mw, handlers.login
app.post '/auth/register',        personal-mw, handlers.register
app.post '/auth/choose-username', personal-mw, handlers.choose-username
app.get  '/auth/user',            personal-mw, handlers.user
app.get  '/auth/verify/:v',       personal-mw, handlers.verify

app.get  '/auth/facebook',        personal-mw, handlers.login-facebook
app.get  '/auth/facebook/return', personal-mw, handlers.login-facebook-return
app.get  '/auth/facebook/finish', personal-mw, handlers.login-facebook-finish

app.get  '/auth/google',          personal-mw, handlers.login-google
app.get  '/auth/google/return',   personal-mw, handlers.login-google-return
app.get  '/auth/google/finish',   personal-mw, handlers.login-google-finish

app.get  '/auth/twitter',         personal-mw, handlers.login-twitter
app.get  '/auth/twitter/return',  personal-mw, handlers.login-twitter-return
app.get  '/auth/twitter/finish',  personal-mw, handlers.login-twitter-finish

app.get  '/auth/logout',          personal-mw, handlers.logout
#}}}
#{{{ Users
app.get '/u/:name', (req, res, next) ->
  res.redirect "/user/#{req.params.name}/", 301

app.get '/user/:name',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.profile

app.get '/user/:name/page/:page',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.profile
#}}}

app.get '/',
  mw.geo,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.homepage

app.get \/search,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.search

app.get '/hello', handlers.hello

app.get '/dynamic/css/:file' handlers.stylus # dynamic serving

app.get '/favicon.ico', (req, res, next) ->
  # replace with real favicon
  next 404, \404

app.get '/:forum/most-active',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

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

#{{{ Development Debug
if process.env.NODE_ENV != \production
  app.get '/debug/sub-posts-tree/:post_id', (req, res, next) ->
    site = res.vars.site
    err, d <- db.sub-posts-tree site.id, req.params.post_id, 25, 0
    if err then return next(err)
    res.json d
#}}}

# vim:fdm=marker
