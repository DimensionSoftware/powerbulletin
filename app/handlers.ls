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
}

global <<< require './helpers'

@hello = (req, res) ->
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

@login-facebook-finish = (req, res, next) ->
  res.send '''
  <script type="text/javascript">
    window.opener.switchAndFocus('.fancybox-wrap', 'on-login', 'on-choose', '#auth input[name=username]');
    window.close();
  </script>
  '''

@login-google = (req, res, next) ->
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('google')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@login-twitter = (req, res, next) ->
  domain   = res.locals.site.domain
  passport = auth.passport-for-site[domain]
  if passport
    passport.authenticate('twitter')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send "500", 500

@logout = (req, res, next) ->
  redirect-url = req.param('redirect-url') || '/'
  req.logout()
  res.redirect redirect-url

@homepage = (req, res, next) ->
  db = pg.procs
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
  db = pg.procs

  #XXX: this is one of the pages which is not depersonalized
  res.locals.user = req.user

  [forum_part, post_part] = req.params

  finish = (adoc) ->
    res.locals adoc
    caching-strategies.etag res, sha1(JSON.stringify(adoc)), 7200
    res.mutant \forum

  # parse uri
  uri = req.path
  sorttype = \recent

  parts = forum-path-parts uri
  uri = uri.replace /\/(edit|new)[\/\d+]*/, '' # strip for lookup
  uri = uri.replace '&?_surf=1', ''
  uri = uri.replace /\?$/, '' # remove ? if its all thats left


  if post_part # post
    tasks =
      menu           : db.menu res.locals.site.id, _
      sub-post       : db.uri-to-post res.locals.site.id, uri, _
      sub-posts-tree : [\subPost, (cb, a) -> db.sub-posts-tree(a.sub-post.id, cb)]
      top-threads    : [\subPost, (cb, a) -> db.top-threads(a.sub-post.forum_id, cb)]

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next(404)
    # attach sub-posts-tree to sub-post toplevel item
    fdoc.sub-post.posts = delete fdoc.sub-posts-tree

    fdoc.active-forum-id = fdoc.sub-post.forum_id
    fdoc.active-post-id  = fdoc.id

    finish fdoc

  else # forum
    tasks =
      menu        : db.menu res.locals.site.id, _
      forum-id    : db.uri-to-forum-id res.locals.site.id, uri, _
      forums      : ['forumId', (cb, a) -> db.forums(a.forum-id, cb)]
      top-threads : ['forumId', (cb, a) -> db.top-threads(a.forum-id, cb)]

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next(404)

    fdoc.active-forum-id = fdoc.forum-id

    finish fdoc

@register = (req, res) ->
  req.assert('login').is-alphanumeric!

  if errors = req.validation-errors!
    res.json {errors}
  else
    res.json req.body

cvars.acceptable-stylus-files = fs.readdir-sync 'app/stylus/'
@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?.length then next 404; return

  render-css = (file-name, cb) ->
    if file-name in cvars.acceptable-stylus-files # concat files
      fs.read-file "app/stylus/#{file-name}", (err, buffer) ->
        if err then return cb(err)

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
  console.warn req.path, req.user, req.cookies
  req.user ||= null
  res.json req.user

@add-impression = (req, res, next) ->
  db = pg.procs
  (err, r) <- db.add-thread-impression req.params.id
  if err then next err
  res.json success: true

@censor = (req, res, next) ->
  db = pg.procs
  (err, r) <- db.censor req.body
  if err then next err
  res.json r

# vim:fdm=indent
