require! {
  express
  mutant
  async
  cors
  \./auth
  \./auth-handlers
  mmw: \mutant/middleware
  pg:  \./postgres
  mw:  \./middleware
  jsu: \./js-urls

  mutants:   \../shared/pb-mutants
  handlers:  \./pb-handlers
  resources: \./pb-resources
}
global <<< require \./server-helpers

# middleware we will use only on personalized routes to save cpu cycles!
personal-mw =
  * cors(origin: '*', credentials: true)
  * express.body-parser!
  * express.cookie-parser!
  * express.cookie-session {secret:cvars.secret, proxy:true, cookie:{proxy:true, secure:true}}
  * auth.mw.initialize
  * auth.mw.session

#{{{ API Resources
app.all      \/resources/*,                 ...personal-mw
app.resource \resources/sites,              resources.sites
app.resource \resources/posts,              resources.posts
app.resource \resources/users,              resources.users
app.resource \resources/products,           resources.products
app.resource \resources/conversations,      resources.conversations
app.resource \resources/threads,            resources.threads
app.get  \/resources/posts/:id/sub-posts,   handlers.sub-posts
app.post \/resources/posts/:id/impression,  handlers.add-impression
app.post \/resources/posts/:id/censor,      handlers.censor
app.post \/resources/users/:id/avatar,      handlers.profile-avatar
app.post   \/resources/forums/:id/background, handlers.forum-background
app.delete \/resources/forums/:id/background, handlers.forum-background-delete
app.put \/resources/users/:id/avatar,       handlers.profile-avatar-crop
#}}}

# common for all pages within a site
#{{{ Common CSS - TODO be specific by site's theme (default, minimal, etc....)
common-css = if process.env.NODE_ENV is \production
  ["#{cvars.cache2-url}/master.css"]
else
  [\/dynamic/css/master.styl] # refresh without building css
#}}}
#{{{ Common JS
common-js = [v for k,v of jsu when k in [
  \jquery
  \jqueryComplexify
  \jqueryCookie
  \jqueryFancybox
  \jqueryHistory
  \jqueryMasonry
  \jqueryTransit
  \jqueryUi
  \jqueryWaypoints
  \raf
  \reactivejs
  \socketio
  \powerbulletin]]
##}}}

# authorization for dreamcodez' blitz.io account
app.get \/mu-d81b9b5a-572eee60-bc2ce3f6-e3fc404b (req, res) -> res.send \42

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

# auth
auth-handlers.apply-to app, personal-mw

#{{{ Users
app.get '/u/:name', (req, res, next) ->
  res.redirect "/user/#{req.params.name}/", 301

app.get '/user/:name',
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.profile

app.get '/user/:name/page/:page',
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.profile
#}}}

app.get '/',
  personal-mw,
  mw.geo,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.homepage

app.get \/search,
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.search

app.get '/hello', handlers.hello

app.get '/dynamic/css/:file' handlers.stylus # dynamic serving

app.get '/favicon.ico', (req, res, next) ->
  # replace with real favicon
  next 404, \404

app.get '/:forum/most-active',
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.forum


# page handler tries to match paths before forum handler
app.get '*',
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
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
  mw.private-site,
  handlers.forum

# forum + post depersonalized
app.all new RegExp('^(.+)/t/(.+)$'),
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.forum

# personal-mw so we can create new posts
app.all new RegExp('^(.+)/new$'),
  personal-mw ++ [
    mw.add-js(common-js),
    mw.add-css(common-css),
  ],
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
  handlers.forum

# bare forum (catch all / depersonalized)
app.all new RegExp('^(.+)$'),
  personal-mw,
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout(\layout, mutants),
  mw.private-site,
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
