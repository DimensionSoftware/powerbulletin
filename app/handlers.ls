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

db = pg.procs

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

@logout = (req, res, next) ->
  redirect-url = req.param('redirect-url') || '/'
  req.logout()
  res.redirect redirect-url

@forum-most-active = (req, res, next) ->
  # nothing

@homepage = (req, res, next) ->
  # TODO: 1 should be replaced with the real site-id here
  # TODO: need to allow ui to change between homepage_recent and homepage_active
  err, doc <- db.doc res.locals.site.id, \homepage_recent, res.locals.site.id
  if err then return next(err)

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
  finish = (doc) ->
    res.locals doc
    caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<< res.locals.site), 7200
    res.mutant \forum

  # parse url
  url = req.path
  if m = url.match /^(.+)\/active$/
    url = m[1]
    sorttype = \active
  else if m = url.match /^(.+)\/recent$/
    url = m[1]
    sorttype = \recent
  else
    # defaults
    # url stays the same
    sorttype = \recent

  parts = forum-path-parts url
  uri = '/' + parts[0].join('/')

  if parts?.length > 1 # thread
    thread-id = parseInt parts[1]

    err, doc <- db.post-doc thread-id, sorttype, uri
    if err then return next err

    if doc?.forums?.length # store active
      doc.active-forum-id = (head filter (.uri is uri), doc.forums)?.id

    console.warn "[thread #{thread-id}] #{req.url}"
    finish doc

  else # forum
    err, fdoc <- db.forum-doc res.locals.site.id, sorttype, uri
    if err then return next err
    if !fdoc then return next(404)
    fdoc.active-forum-id = fdoc.forums[0]?.id
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

# vim:fdm=indent
