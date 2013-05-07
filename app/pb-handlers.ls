require! {
  fs
  async
  jade
  stylus
  cssmin
  fluidity
  mkdirp
  __:   \lodash
  pg:   \./postgres
  auth: \./auth
  furl: \./forum-urls
  t: \./tasks
}

announce = require(\socket.io-announce).create-client!

global <<< require \./helpers
global <<< require \./shared-helpers

is-editing = /\/(edit|new)\/?([\d+]*)$/
is-admin   = /\/admin.+/

@hello = (req, res, next) ->
  console.log req.headers
  res.send "hello #{res.vars.remote-ip}!"

@login = (req, res, next) ->
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
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
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('facebook')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-facebook-return = (req, res, next) ->
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
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
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
  scope    = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'

  if passport
    passport.authenticate('google', {scope})(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-return = (req, res, next) ->
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('google', { success-redirect: '/auth/google/finish', failure-redirect: '/auth/google/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-finish = auth-finisher

@login-twitter = (req, res, next) ->
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('twitter')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter-return = (req, res, next) ->
  domain   = res.vars.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('twitter', { success-redirect: '/auth/twitter/finish', failure-redirect: '/auth/twitter/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter-finish = auth-finisher

@logout = (req, res, next) ->
  if req.user # guard
    redirect-url = req.param('redirect-url') || '/'
    req.logout!
    res.redirect redirect-url.replace(is-editing, '')

@homepage = (req, res, next) ->
  order = req.query.order

  tasks =
    menu:   db.menu res.vars.site.id, _
    forums: db.homepage-forums res.vars.site.id, order, _
  err, doc <- async.auto tasks

  # all handlers should aspire to stuff as much non-personalized or non-time-sensitive info in a static doc
  # for O(1) retrieval (assuming hashed index map)
  doc?.active-forum-id = \homepage
  res.locals doc

  # TODO fetch smart/fun combination of latest/best voted posts, posts & media
  announce.emit \debug, {testing: 'from homepage handler in express'}

  # XXX: this should be abstracted into a pattern, middleware or pure function
  caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<<  res.vars.site), 7200
  res.content-type \html
  res.mutant \homepage

@forum = (req, res, next) ->
  db   = pg.procs
  user = req.user
  uri  = req.path

  meta = furl.parse req.path
  console.warn meta.type, meta.path
  res.locals.furl = meta

  # guards
  if meta.incomplete
    #console.error meta
    return next 404
  if meta.type in <[new-thread edit]>
    return next 404 unless user # editing!  so, must be logged in
  err, owns-post <- db.owns-post meta.id, user?.id
  if err then return next err
  if meta.type is \edit
    return next 404 unless owns-post.length

  #XXX: this is one of the pages which is not depersonalized
  res.locals.user = user
  site = res.vars.site
  delete site.config

  [forum_part, post_part] = req.params

  finish = (adoc) ->
    adoc.uri = req.path
    res.locals adoc
    caching-strategies.etag res, sha1(JSON.stringify(adoc)), 7200
    res.mutant \forum

  if post_part # post
    err, post <- db.uri-to-post site.id, meta.thread-uri
    if err then return next err
    if !post then return next 404

    page = meta.page || 1
    if page < 1 then return next 404

    limit = 5
    offset = (page - 1) * 5

    tasks =
      menu            : db.menu site.id, _
      sub-posts-tree  : db.sub-posts-tree site.id, post.id, limit, offset, _
      sub-posts-count : db.sub-posts-count post.id, _
      top-threads     : db.top-threads post.forum_id, \recent, _
      forum           : db.forum post.forum_id, _

    if req.surfing
      this-mutant = t.for-mutant.thread
      last-mutant = t.for-mutant[req.param._surf]
      diff = t.required-tasks [this-mutant, {}] [last-mutant, {}]

    err, fdoc <- async.auto tasks
    if err   then return next err
    if !fdoc then return next 404
    if page > 1 and fdoc.sub-posts-tree.length < 1 then return next 404

    # attach sub-post to fdoc, among other things
    fdoc <<< {post, forum-id:post.forum_id, page}
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

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next 404

    fdoc <<< {forum-id}
    fdoc.active-forum-id = fdoc.forum-id

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

  err, fdoc <- async.auto tasks
  if err then return next err
  fdoc.furl = thread-uri: "/user/#name"  # XXX - a hack to fix the pager that must go away
  fdoc.page = parse-int page
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
  domain   = site.domain
  passport = auth.passport-for-site[domain]

  # TODO more validation
  req.assert('username').not-empty!is-alphanumeric!  # .len(min, max) .regex(/pattern/)
  req.assert('password').not-empty!  # .len(min, max) .regex(/pattern/)
  req.assert('email').is-email!

  if errors = req.validation-errors!
    console.warn 'you fucked up', errors
    res.json {errors}
  else
    username = req.body.username
    password = req.body.password
    email    = req.body.email

    err, r <~ db.name-exists name: username, site_id: site.id
    user-id = 0
    if err
      return res.json success: false, errors: err
    else if r
      console.warn 'username already exists', r
      res.json success: false, errors: []
    else
      err, vstring <~ auth.unique-verify-string-for-site site.id
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
        return res.json success: false, errors: err
      else
        # on successful registration, automagically @login, too
        auth.send-registration-email u, site, (err, r) ->
          console.warn 'registration email', err, r
        #@login(req, res, next)
        res.json { success: true, errors: [] }

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

cvars.acceptable-stylus-files = fs.readdir-sync 'app/stylus/'
@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?.length then next 404; return

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
          .set \paths ['app/stylus']
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

  err, sub-posts <- db.sub-posts-tree res.vars.site.id, post-id, limit, offset
  if err then return next err

  res.json sub-posts

@admin = (req, res, next) ->
  if not req?user?rights?super then return next 404 # guard
  site = res.vars.site
  res.locals.action = req.param \action
  tasks =
    menu: db.menu site.id, _
    auth: db.site-by-id site.id, _
  err, fdoc <- async.auto tasks
  if err then return next err
  res.locals fdoc
  res.mutant \admin

@search = (req, res, next) ->
  site = res.vars.site
  elquery =
    index: \pb
    type: \post

  var q
  if req.query.q
    q = req.query.q.to-lower-case!
    announce.emit \register-query q


  elquery.query = q

  err, menu <- db.menu res.vars.site.id
  if err then return next err
  res.locals {menu}

  err, elres <- elc.search elquery
  if err then return next(err)
  res.locals {elres}

  res.locals.searchopts = {q: req.query.q}

  res.mutant \search
# vim:fdm=indent
