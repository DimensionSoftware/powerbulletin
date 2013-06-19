require! {
  cssmin
  express
  mutant
  async
  \./auth
  \express-validator
  mmw: \mutant/middleware
  pg:  \./postgres
  mw:  \./middleware
  jsu: \./js-urls

  mutants:   \./pb-mutants
  handlers:  \./pb-handlers
  resources: \./pb-resources
}
global <<< require \./server-helpers

# middleware we will use only on personalized routes to save cpu cycles!
personal-mw =
  * express-validator
  * express.body-parser!
  * express.cookie-parser!
  * express.cookie-session {secret:cvars.secret}
  * auth.mw.initialize
  * auth.mw.session

#{{{ API Resources
app.all      \/resources/*,                ...personal-mw
app.resource \resources/sites,             resources.sites
app.resource \resources/posts,             resources.posts
app.resource \resources/users,             resources.users
app.resource \resources/products,          resources.products
app.resource \resources/conversations,     resources.conversations
app.get  \/resources/posts/:id/sub-posts,  handlers.sub-posts
app.post \/resources/posts/:id/impression, handlers.add-impression
app.post \/resources/posts/:id/censor,     handlers.censor
app.post \/resources/users/:id/avatar,     handlers.profile-avatar
#}}}

# common is for all environments
common-css = [\/dynamic/css/master.styl]
#{{{ Common JS
common-js = [v for k,v of jsu when k in [
  \jquery
  \jqueryComplexify
  \jqueryCookie
  \jqueryFancybox
  \jqueryHistory
  \jqueryHistoryNative
  \jqueryMasonry
  \jqueryNicescroll
  \jqueryTransit
  \jqueryUi
  \jqueryWaypoints
  \raf
  \reactivejs
  \socketio
  \powerbulletin]]
##}}}

# inject testing code in dev only
app.configure \development ->
  entry = common-js.pop!
  common-js.push "#{cvars.cache5-url}/local/mocha.js"
  common-js.push "#{cvars.cache5-url}/local/chai.js"
  common-js.push entry

#{{{ Admin
app.get \/admin/:action?,
  personal-mw.concat(
    , mw.require-admin
    , mw.add-js(common-js)
    , mw.add-css(common-css)
    , mmw.mutant-layout(\layout, mutants)
  ),
  handlers.admin
#}}}

# MISC AJAX
app.post '/ajax/checkout/:productId', personal-mw, handlers.checkout

#{{{ Local auth
#
app.post '/auth/login',           personal-mw, handlers.login
app.post '/auth/register',        personal-mw, handlers.register
app.post '/auth/choose-username', personal-mw, handlers.choose-username
app.get  '/auth/user',            personal-mw, handlers.user
app.get  '/auth/verify/:v',       personal-mw, handlers.verify
app.post '/auth/forgot',          personal-mw, handlers.forgot
app.post '/auth/forgot-user'      personal-mw, handlers.forgot-user
app.post '/auth/reset-password'   personal-mw, handlers.reset-password

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


# page handler tries to match paths before forum handler
app.get '*',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.page

# XXX: TODO, FURL needs to take into account these cases so i can get rid of dependent
# hacky regexps:
# * /new/new
# * /t/ is a forum?
# * need to know about distinct state 'edit post'
# * need to know about distinct state 'new post'
#
# if the above is satisfied, then i can stop capturing below ()
# and stop using captured params in the handler itself
# instead furl will provide all i need..
# these regexps at that point will only serve to differentiate
# between running the personalize mw or not

# personal-mw so we can edit posts
app.all new RegExp('^(.+)/t/([^/]+/edit/[^/]+)$'),
  personal-mw ++ [
    mw.add-js(common-js),
    mw.add-css(common-css),
  ],
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

# forum + post depersonalized
app.all new RegExp('^(.+)/t/(.+)$'),
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

# personal-mw so we can create new posts
app.all new RegExp('^(.+)/new$'),
  personal-mw ++ [
    mw.add-js(common-js),
    mw.add-css(common-css),
  ],
  mmw.mutant-layout(\layout, mutants),
  handlers.forum

# bare forum (catch all / depersonalized)
app.all new RegExp('^(.+)$'),
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
