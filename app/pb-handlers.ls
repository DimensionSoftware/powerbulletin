require! {
  fs
  async
  jade
  stylus
  cssmin
  fluidity
  mkdirp
  querystring
  __:   \lodash
  pg:   \./postgres
  auth: \./auth
  furl: \./forum-urls
  s: \./search
}

announce = require(\socket.io-announce).create-client!

global <<< require \./helpers
global <<< require \./shared-helpers

is-editing = /\/(edit|new)\/?([\d+]*)$/
is-admin   = /\/admin.*/

@hello = (req, res, next) ->
  console.log req.headers
  res.send "hello #{res.vars.remote-ip}!"

@login = (req, res, next) ->
  domain   = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    console.warn "domain", domain

    auth-response = (err, user, info) ->
      if err then return next(err)
      if not user then return res.json { success: false }
      req.login user, (err) ->
        if err then return next(err)
        res.json { success: true }

    passport.authenticate('local', auth-response)(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@forgot = (req, res, next) ->
  db    = pg.procs
  site  = res.vars.site
  email = req.body.email

  console.warn req.header \Referrer

  if not email
    res.json success: false, errors: [ 'Blank email' ]
    return

  err, user <- db.usr { email, site_id: site.id }
  if err
    res.json success: false, errors: [ err ]
    return

  console.log \user, user
  if user
    err, user-forgot <- auth.user-forgot-password user
    if err
      res.json success: false, errors: [ err ]
      return
    console.log \user-forgot, user-forgot

    err <- auth.send-recovery-email user-forgot, site
    if err
      res.json success: false, errors: [ err ]
    else
      res.json success: true
  else
    res.json success: false, errors: [ 'User not found' ]

@forgot-user = (req, res, next) ->
  site = res.vars.site
  hash = req.body.forgot
  err, user <- db.usr forgot: hash, site_id: site.id
  if err
    return res.json success: false, errors: [ err ]
  if user
    res.json success: true
  else
    res.json success: false, errors: [ "User not found" ]

@reset-password = (req, res, next) ->
  site = res.vars.site
  hash = req.body.forgot
  password = req.body.password

  err, user <- db.usr forgot: hash, site_id: site.id
  if err
    console.warn \usr, err
    return res.json success: false, errors: [ err ]

  if user
    auths-local = user.auths.local
    auths-local.password = auth.hash password
    auths-json = JSON.stringify auths-local
    err <- db.auths.update criteria: { type: \local, user_id: user.id }, data: { profile: auths-json }
    if err
      console.warn \auths-update, err
      return res.json success: false, errors: [ err ]

    err <- db.alias-blank user
    if err
      console.warn \alias-blank, err
      return res.json success: false, errors: [ err ]

    res.json success: true
  else
    console.warn \usr, "User not found"
    res.json success: false, errors: [ "User not found" ]

# TODO - validate username
@choose-username = (req, res, next) ->
  if not req.user
    return res.send "500", 500
  db = pg.procs
  usr =
    user_id : req.user.id
    site_id : req.user.site_id
    name    : req.body.username
  (err, r) <- db.change-alias usr
  if err then return res.send "500", 500
  console.warn "Changed name to #{req.body.username}"
  req.session?.passport?.user = "#{req.body.username}:#{req.user.site_id}"
  res.redirect req.header 'Referer'

@login-facebook = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('facebook')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-facebook-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('facebook', { success-redirect: '/auth/facebook/finish', failure-redirect: '/auth/facebook/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

auth-finisher = (req, res, next) ->
  user = req.user
  first-visit = user.created_human.match /just now/i
  if first-visit
    res.send """
    <script type="text/javascript">
      window.opener.$('\#auth input[name=username]').val('#{user.name}');
      window.opener.switchAndFocus('on-login', 'on-choose', '\#auth input[name=username]');
      window.close();
    </script>
    """
  else
    res.send """
    <script type="text/javascript">
      window.opener.$.fancybox.close();
      window.opener.afterLogin();
      window.close();
    </script>
    """

@login-facebook-finish = auth-finisher

@login-google = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  scope    = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'

  if passport
    passport.authenticate('google', {scope})(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('google', { success-redirect: '/auth/google/finish', failure-redirect: '/auth/google/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-finish = auth-finisher

@login-twitter = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('twitter')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('twitter', { success-redirect: '/auth/twitter/finish', failure-redirect: '/auth/twitter/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter-finish = auth-finisher

@logout = (req, res, next) ->
  if req.user # guard
    redirect-url = req.param(\redirect-url) or req.header(\Referer) or '/'
    req.logout!
    res.redirect redirect-url.replace(is-editing, '').replace(is-admin, '')

# remove unnecessary data from res.locals when surfing
# @param Object res   response object
# @returns Object     modified locals
delete-unnecessary-surf-data = (res) ->
  locals = res.locals
  unnecessary =
     \siteName
     \cache2Url # keeping cacheUrl
     \cache3Url
     \cache4Url
     \cache5Url
     \jsUrls
     \cssUrls
  for i in unnecessary
    delete locals[i]
  locals

# remove tasks that don't have to be run when surfing
# @param Object tasks         hashmap of tasks to be given to async.auto
# @param String keep-string   comma-separated list of tasks to be kept
# @returns Object             a new, smaller set of tasks
delete-unnecessary-surf-tasks = (tasks, keep-string) ->
  always-keep = <[ subPostsCount ]>
  keep = always-keep ++ keep-string.split ','
  t = { [k, v] for k, v of tasks when k in keep }

@homepage = (req, res, next) ->
  tasks =
    menu:   db.menu res.vars.site.id, _
    forums: db.homepage-forums res.vars.site.id, (req.query?order or \recent), _
  if req.surfing
    delete tasks.menu
    delete-unnecessary-surf-data res

  err, doc <- async.auto tasks

  # TODO fetch smart/fun combination of latest/best voted posts, posts & media
  # unique users at thread level
  # - better handled in sql
  uniq = {}
  doc.forums = doc.forums |> filter (f) ->
    k = f.user_id + f.thread_id
    r=uniq[k]
    unless r # add!
      return uniq[k]=true
    false

  doc.active-forum-id = \homepage
  doc.title = res.vars.site.name
  res.locals doc
  res.locals.active-forum-id = \homepage

  announce.emit \debug, {testing: 'from homepage handler in express'}

  # XXX: this should be abstracted into a pattern, middleware or pure function
  # cache homepage for 60s
  caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<<  res.vars.site), 60s
  res.content-type \html
  res.mutant \homepage

@forum = (req, res, next) ->
  db   = pg.procs
  user = req.user
  uri  = req.path

  meta = furl.parse querystring.unescape(req.path)
  console.warn meta.type, meta.path
  res.locals.furl = meta

  # guards
  if meta.incomplete
    #console.error meta
    return next 404
  if meta.type in <[new-thread edit]>
    return next 404 unless user # editing!  so, must be logged in

  #XXX: this is one of the pages which is not depersonalized
  res.locals.user = user
  site = res.vars.site

  [forum_part, post_part] = req.params

  finish = (adoc) ->
    adoc.uri = req.path
    res.locals adoc

    # indefinite / manual invalidation caching for forums threads and sub-post pages
    caching-strategies.etag res, sha1(JSON.stringify(adoc)), 0s
    res.header \x-varnish-ttl \24h
    res.mutant \forum

  if post_part # post
    err, post <- db.uri-to-post site.id, meta.thread-uri
    if err then return next err
    if !post then return next 404

    page = meta.page || 1
    if page < 1 then return next 404

    limit = site.config?posts-per-page || 20
    offset = (page - 1) * limit

    tasks =
      menu            : db.menu site.id, _
      sub-posts-tree  : db.sub-posts-tree site.id, post.id, 'p.*', limit, offset, _
      sub-posts-count : db.sub-posts-count post.id, _
      top-threads     : db.top-threads post.forum_id, \recent, _
      forum           : db.forum post.forum_id, _

    if req.surfing
      delete-unnecessary-surf-data res
      if req.query._surf-tasks
        tasks = delete-unnecessary-surf-tasks tasks, req.query._surf-tasks
      else
        delete tasks.menu

    err, fdoc <- async.auto tasks
    console.warn err, keys(fdoc)
    if err   then return next err
    if !fdoc then return next 404
    if page > 1 and fdoc.sub-posts-tree.length < 1 then return next 404

    # attach sub-post to fdoc, among other things
    fdoc <<< {post, forum-id:post.forum_id, page}
    fdoc.title = post.title
    # attach sub-posts-tree to sub-post toplevel item
    fdoc.post.posts = delete fdoc.sub-posts-tree
    fdoc.pages-count = Math.ceil(delete fdoc.sub-posts-count / limit)

    fdoc.active-forum-id  = fdoc.post.forum_id
    fdoc.active-thread-id = post.id

    finish fdoc

  else # forum
    err, forum-id <- db.uri-to-forum-id res.vars.site.id, meta.forum-uri
    if err then return next err
    if !forum-id then return next 404
    tasks =
      menu        : db.menu res.vars.site.id, _
      forum       : db.forum forum-id, _
      forums      : db.forum-summary forum-id, 10, 5, _
      top-threads : db.top-threads forum-id, \recent, _

    if req.surfing
      delete-unnecessary-surf-data res
      if req.query._surf-tasks
        tasks = delete-unnecessary-surf-tasks tasks, req.query._surf-tasks
      else
        delete tasks.menu

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next 404

    fdoc <<< {forum-id}
    fdoc.active-forum-id = fdoc.forum-id
    fdoc.title = fdoc?forum?title

    finish fdoc

# user profiles /user/:name
@profile = (req, res, next) ->
  db   = pg.procs
  site = res.vars.site
  name = req.params.name
  page = req.params.page or 1
  ppp  = 20 # posts-per-page
  usr  = { name: name, site_id: site.id }

  tasks =
    menu           : db.menu site.id, _
    profile        : db.usr usr, _
    posts-by-user  : db.posts-by-user usr, page, ppp, _
    pages-count    : db.posts-by-user-pages-count usr, ppp, _

  if req.surfing
    delete tasks.menu
    delete-unnecessary-surf-data res

  err, fdoc <- async.auto tasks
  if err then return next err
  fdoc.furl = thread-uri: "/user/#name"  # XXX - a hack to fix the pager that must go away
  fdoc.page = parse-int page
  fdoc.title = name
  with fdoc.profile # transform
    ..human_post_count = add-commas(..post_count.to-string!)

  res.locals fdoc
  res.mutant \profile

@profile-avatar = (req, res, next) ->
  db   = pg.procs
  user = req.user
  site = res.vars.site
  err, usr <- db.usr { id: req.params.id, site_id: site.id }
  if err
    console.error \authentication
    return res.json { success: false }, 403
  if usr.name != user.name
    console.error \authorization
    return res.json { success: false }, 403

  avatar = req.files.avatar

  ext = avatar.name.match(/\.(\w+)$/)?1 or ""
  avatar-file = if ext then "avatar.#ext" else "avatar"

  # mkdirp public/images/user/:user_id
  url-dir-path = "/images/user/#{user.id}"
  fs-dir-path  = "public#url-dir-path"
  url-path     = "#url-dir-path/#{avatar-file}"
  fs-path      = "#fs-dir-path/#{avatar-file}"
  err <- mkdirp fs-dir-path
  if err
    console.error \mkdirp.rename, err
    return res.json { success: false }, 403

  # move image to public/images/user/:user_id/
  move = (src, dst, cb) ->
    _is = fs.create-read-stream src
    _os = fs.create-write-stream dst
    _is.on \end, (err) ->
      err2 <- fs.unlink src
      cb(err)
    _is.pipe(_os)

  err <- move avatar.path, fs-path
  if err
    console.error \move, err
    return res.json { success: false }, 403

  # update user avatar
  err, success <- db.change-avatar user, url-path
  if err
    console.error \change-avatar, err
    return res.json { success: false }, 403
  res.json success: true, avatar: url-path

@register = (req, res, next) ~>
  site     = res.vars.site
  domain   = site.current_domain
  passport = auth.passport-for-domain[domain]

  # TODO more validation
  req.assert('username').not-empty!is-alphanumeric!  # .len(min, max) .regex(/pattern/)
  req.assert('password').not-empty!  # .len(min, max) .regex(/pattern/)
  req.assert('email').is-email!

  if errors = req.validation-errors!
    console.warn errors
    res.json {errors}
  else
    username = req.body.username
    password = req.body.password
    email    = req.body.email

    err, r <~ db.name-exists name: username, site_id: site.id
    user-id = 0
    if err
      return res.json success: false, errors:[msg:'Account in-use']
    else if r
      res.json success: false, errors:[msg:'User name in-use']
    else
      err, vstring <~ auth.unique-hash \verify, site.id
      if err then return next err
      u =
        type    : \local
        profile : { password: auth.hash(password) }
        site_id : site.id
        name    : username
        email   : email
        verify  : vstring

      err, r <~ db.register-local-user u # couldn't use find-or-create-user because we don't know the id beforehand for local registrations
      if err
        return res.json success: false, errors: [ err ]

      auth.send-registration-email u, site, (err, r) ->
        console.warn 'registration email', err, r
      #@login(req, res, next) # on successful registration, automagically @login, too
      res.json success: true, errors: []

@verify = (req, res, next) ->
  v    = req.param \v
  site = res.vars.site
  err, r <- db.verify-user site.id, v
  if err then return next err
  if r
    req.session?passport?user = "#{r.name}:#{site.id}"
    res.redirect '/#validate'
  else
    res.redirect '/#invalid'

cvars.acceptable-stylus-files = fs.readdir-sync \app/stylus/
@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?length then return next 404

  render-css = (file-name, cb) ->
    if file-name in cvars.acceptable-stylus-files # concat files
      fs.read-file "app/stylus/#{file-name}", (err, buffer) ->
        if err then return cb err

        options =
          compress: true
        stylus(buffer.to-string!, options)
          .define \cache-url  cvars.cache-url
          .define \cache2-url cvars.cache2-url
          .define \cache3-url cvars.cache3-url
          .define \cache4-url cvars.cache4-url
          .define \cache5-url cvars.cache5-url
          .set \paths [\app/stylus]
          .use fluidity!
          .render cb
    else
      cb 404

  async.map files, render-css, (err, css-blocks) ->
    if err then return next err
    blocks = css-blocks.join "\n"
    #body   = if process.env.NODE_ENV is \production then cssmin.cssmin(blocks, 100) else blocks
    body = blocks # cssmin broken? XXX: fix or remove
    caching-strategies.etag res, sha1(body), 7200
    res.content-type 'css'
    res.send body

@user = (req, res, next) ->
  req.user ||= null
  if req.user
    res.json __.omit(req.user, \auths)
  else
    res.json null

@add-impression = (req, res, next) ->
  db = pg.procs
  (err, r) <- db.add-thread-impression req.params.id
  if err then next err
  site = res.vars.site
  # TODO make add-thread-impression return forum_id
  # TODO make room name based on site.id and forum_id
  announce.in(site.id).emit \thread-impression r #{ id: req.params.id, views: r.views, forum_id: r.thread_id }
  res.json success: true

@censor = (req, res, next) ->
  return next(404) unless req.user
  db = pg.procs

  # XXX: stub for reason, need to have ui to capture moderation reason
  command = req.body <<< {
    user_id: req.user.id
    post_id: req.params.id
    reason: \STUBBBBBB # XXX: fix me
  }

  (err, r) <- db.censor command
  if err then next err
  res.json r

@sub-posts = (req, res, next) ->
  post-id = parse-int(req.params.id) || null
  if post-id is null then return next(404)

  page = parse-int(req.query.page) || 1
  if page < 1 then return next(404)

  limit = 5
  offset = (page - 1) * limit

  err, sub-posts <- db.sub-posts-tree res.vars.site.id, post-id, 'p.*', limit, offset
  if err then return next err

  res.json sub-posts

@admin = (req, res, next) ->
  if not req?user?rights?super then return next 404 # guard
  site = res.vars.site
  res.locals.action = req.param \action

  tasks =
    menu: db.menu site.id, _
    site: db.site-by-id site.id, _

  if req.surfing
    delete tasks.menu
    delete-unnecessary-surf-data res

  err, fdoc <- async.auto tasks
  if err then return next err

  # default
  fdoc.themes =
    * id:1 name:'PowerBulletin Minimal'
    * id:0 name:\None
  defaults =
    posts-per-page: 30
    meta-keywords: "#{site.name}, PowerBulletin"
  fdoc.site.config = defaults <<< fdoc.site.config
  fdoc.title = \Admin
  res.locals fdoc

  res.mutant \admin # out!

@search = (req, res, next) ->
  site = res.vars.site

  err, menu <- db.menu res.vars.site.id
  if err then return next err

  err, elres <- s.search req.query
  if err then return next(err)

  for h in elres.hits
    h._source.posts = [] # stub object for non-existent sub-posts in search view

  res.locals {elres}

  cleanup-searchopts = (opts) ->
    const key-blacklist =
      * \_surf
      * \_surfData
      * \_surfTasks

    opts = {} <<< opts

    for key in key-blacklist
      delete opts[key]

    return opts

  res.locals.searchopts = cleanup-searchopts req.query
  res.locals {menu, title: "Search : #{res.locals.searchopts.q}"}

  res.mutant \search
# vim:fdm=indent
