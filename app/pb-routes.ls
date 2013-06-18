require! {
  cssmin
  express
  mutant
  async
  \./auth
  \./auth-handlers
  \express-validator
  mmw: \mutant/middleware
  pg:  \./postgres
  mw:  \./middleware

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

# XXX Common is for all environments
common-js = [ #{{{ Common JS
  "#{cvars.cache2-url}/local/jquery-1.9.1.min.js",
  "#{cvars.cache3-url}/local/jquery-ui.min.js",
  "#{cvars.cache4-url}/local/jquery.masonry.min.js",
  "#{cvars.cache5-url}/local/jquery.cookie-1.3.1.min.js",
  "#{cvars.cache-url}/local/waypoints.min.js",
  "#{cvars.cache2-url}/local/history.min.js",
  "#{cvars.cache3-url}/local/history.adapter.native.min.js",
  "#{cvars.cache4-url}/fancybox/jquery.fancybox.pack.js",
  "#{cvars.cache5-url}/local/jquery.transit-0.9.9.min.js",
  "#{cvars.cache-url}/local/reactive.js",
  "#{cvars.cache2-url}/local/jquery.nicescroll.min.js",
  "#{cvars.cache4-url}/local/raf.js",
  "#{cvars.cache5-url}/socket.io/socket.io.js",
  "#{cvars.cache-url}/powerbulletin#{if process.env.NODE_ENV is \production then '.min' else ''}.js"]
#}}}
common-css = [ #{{{ Common CSS
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
    , mw.require-admin
    , mw.add-js(common-js)
    , mw.add-css(common-css)
    , mmw.mutant-layout(\layout, mutants)
  ),
  handlers.admin
#}}}

auth-handlers.init-with-app app, personal-mw

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
