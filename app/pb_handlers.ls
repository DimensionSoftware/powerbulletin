require! {
  fs
  async
  jade
  stylus
  cssmin
  fluidity
  __: \lodash
  pg: './postgres'
  auth: './auth'
  sioa: 'socket.io-announce'
  furl: './forum_urls'
}

announce = sioa.create-client!
is-editing = /\/(edit|new)\/?([\d+]*)$/

global <<< require './helpers'

@hello = (req, res, next) ->
  console.log req.headers
  console.log req.foo.bar
  res.send "hello #{res.locals.remote-ip}!"

@login = (req, res, next) ->
  domain   = res.locals.site.domain
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
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('facebook')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-facebook-return = (req, res, next) ->
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('facebook', { success-redirect: '/auth/facebook/finish', failure-redirect: '/auth/facebook/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

auth-finisher = (req, res, next) ->
  user = req.user
  console.warn 'user', user
  first-visit = user.created_human.match /just now/
  if first-visit
    res.send """
    <script type="text/javascript">
      window.opener.$('\#auth input[name=username]').val('#{user.name}');
      window.opener.switchAndFocus('.fancybox-wrap', 'on-login', 'on-choose', '\#auth input[name=username]');
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
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  scope    = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'

  if passport
    passport.authenticate('google', {scope})(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-return = (req, res, next) ->
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('google', { success-redirect: '/auth/google/finish', failure-redirect: '/auth/google/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-google-finish = auth-finisher

@login-twitter = (req, res, next) ->
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('twitter')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter-return = (req, res, next) ->
  domain   = res.locals.site.domain
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
  #TODO: refactor with async.auto
  err, menu <- db.menu res.locals.site.id
  if err then return next err
  err, forums <- db.homepage-forums res.locals.site.id
  if err then return next err
  doc = {menu, forums}

  # all handlers should aspire to stuff as much non-personalized or non-time-sensitive info in a static doc
  # for O(1) retrieval (assuming hashed index map)
  doc?.active-forum-id = \homepage
  res.locals doc

  # TODO fetch smart/fun combination of latest/best voted posts, posts & media

  # XXX: this should be abstracted into a pattern, middleware or pure function
  caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<<  res.locals.site), 7200
  res.content-type \html
  res.mutant \homepage

@forum = (req, res, next) ->
  db   = pg.procs
  user = req.user
  uri  = req.path

  meta = furl.parse req.path
  console.log meta

  # guards
  if meta.incomplete
    console.error meta
    return next 404
  if meta.type in <[new-thread edit]>
    return next 404 unless user # editing!  so, must be logged in
  err, owns-post <- db.owns-post meta.id, user?.id
  if err then return next err
  if meta.type is \edit
    return next 404 unless owns-post.length

  #XXX: this is one of the pages which is not depersonalized
  res.locals.user = user
  site = res.locals.site
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

    err, fdoc <- async.auto tasks
    if err   then return next err
    if !fdoc then return next 404
    if page > 1 and fdoc.sub-posts-tree.length < 1 then return next 404

    # attach sub-post to fdoc, among other things
    fdoc <<< {post, forum-id:post.forum_id, page}
    # attach sub-posts-tree to sub-post toplevel item
    fdoc.post.posts = delete fdoc.sub-posts-tree
    fdoc.pages-count = Math.ceil(delete fdoc.sub-posts-count / limit)
    fdoc.pages = [1 to fdoc.pages-count]
    if page > 1
      fdoc.prev-pages = [1 til page]
    else
      fdoc.prev-pages = []

    fdoc.active-forum-id = fdoc.post.forum_id
    fdoc.active-post-id  = post.id

    finish fdoc

  else # forum
    err, forum-id <- db.uri-to-forum-id res.locals.site.id, meta.forum-uri
    if err then return next err
    if !forum-id then return next 404
    tasks =
      menu        : db.menu res.locals.site.id, _
      forum       : db.forum forum-id, _
      forums      : db.forums forum-id, _
      top-threads : db.top-threads forum-id, \recent, _

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next 404

    fdoc <<< {forum-id}
    fdoc.active-forum-id = fdoc.forum-id
    fdoc.pages = [1] # XXX - @matt - what's the right value to put here?

    finish fdoc

# user profiles /user/:name
@profile = (req, res, next) ->
  site = res.locals.site

  tasks =
    menu           : db.menu site.id, _

  err, fdoc <- async.auto tasks
  if err then return next err

  res.locals fdoc
  res.mutant \profile

@register = (req, res, next) ~>
  site     = res.locals.site
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
  site = res.locals.site
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
          .define \cache_url  cvars.cache_url
          .define \cache2_url cvars.cache2_url
          .define \cache3_url cvars.cache3_url
          .define \cache4_url cvars.cache4_url
          .define \cache5_url cvars.cache5_url
          .set \paths ['app/stylus']
          .use fluidity!
          .render cb
    else
      cb 404

  async.map files, render-css, (err, css-blocks) ->
    if err then return next err
    blocks = css-blocks.join "\n"
    body   = if process.env.NODE_ENV is \production then cssmin.cssmin blocks 1000 else blocks
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
  site = res.locals.site
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

  err, sub-posts <- db.sub-posts-tree res.locals.site.id, post-id, limit, offset
  if err then return next err

  res.json sub-posts

@admin = (req, res, next) ->
  site = res.locals.site

  tasks =
    menu           : db.menu site.id, _

  err, fdoc <- async.auto tasks
  if err then return next err

  res.locals fdoc

  res.mutant \admin

# vim:fdm=indent
