require! {
  fs
  async
  jade
  mkdirp
  querystring
  s: \./search
  c: \./cache
  __:   \lodash
  pg:   \./postgres
  auth: \./auth
  furl: \./forum-urls
  pay: \./payments
  url
}

announce = require(\socket.io-announce).create-client!

global <<< require \./server-helpers
global <<< require \./shared-helpers
global <<< require \./client-helpers

{is-editing, is-admin, is-auth} = require \./path-regexps

posts-per-page = 30

@hello = (req, res, next) ->
  console.log req.headers
  res.send "hello #{res.vars.remote-ip}!"

# remove unnecessary data from res.locals when surfing
# @param Object res   response object
# @returns Object     modified locals
delete-unnecessary-surf-data = (res) ->
  locals = res.locals
  unnecessary =
     \siteName
     \analytics
     \inviteOnly
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
  # TODO fetch smart/fun combination of latest/best voted posts, posts & media
  site-id = res.vars.site.id
  tasks =
    menu:   db.menu site-id, _
    forums: db.site-summary site-id, 6threads, (req.query?order or \recent), _

  if req.surfing
    delete tasks.menu
    delete-unnecessary-surf-data res

  err, doc <- async.auto tasks
  doc.forums          = filter (.posts.length), doc.forums
  doc.title           = res.vars.site.name
  doc.active-forum-id = \homepage
  res.locals doc

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

    limit = site.config?posts-per-page or posts-per-page
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
    fdoc.qty = parse-int(delete fdoc.sub-posts-count)
    fdoc.limit = parse-int limit
    fdoc.pages-count = Math.ceil(fdoc.qty / fdoc.limit)
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
      forums      : db.forum-summary forum-id, 10threads, \recent, _
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
  ppp  = posts-per-page
  usr  = { name: name, site_id: site.id }

  if req.params.page
    req.assert(\page, 'Invalid page number').isInt()

  errors = req.validation-errors!
  if errors
    err = new Error errors.0?msg
    err.non-fatal = true
    return next err

  tasks =
    menu           : db.menu site.id, _
    profile        : db.usr usr, _
    posts-by-user  : db.posts-by-user usr, page, ppp, _
    qty            : [\profile, (cb, a) ->
      db.posts-count-by-user(a.profile, cb)
    ]
    pages-count    : db.posts-by-user-pages-count usr, ppp, _

  if req.surfing
    delete tasks.menu
    delete-unnecessary-surf-data res

  err, fdoc <- async.auto tasks
  if err then return next err
  unless fdoc.profile then return next 404 # guard
  fdoc.furl  = thread-uri: "/user/#name" # XXX - a hack to fix the pager that must go away
  fdoc.page  = parse-int page
  fdoc.title = name
  with fdoc.profile # transform
    ..human_post_count = add-commas(..post_count)

  res.locals fdoc
  res.locals.step = 2 #ppp

  # i know this is hacky, XXX use proper parsing later
  res.locals.uri = req.url
  res.locals.uri =
    res.locals.uri.replace /(_surf=[^&]*&?)|(_surfData=[^&]*&?)/, ''
  res.locals.uri =
    res.locals.uri.replace /\?$/, ''
  res.locals.limit = ppp

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

@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?length then return next 404

  async.map files, render-css, (err, css-blocks) ->
    if err then return next err
    body = css-blocks.join "\n"
    caching-strategies.etag res, sha1(body), 7200
    res.content-type \css
    res.send body

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
  return next 404 unless req.user
  db = pg.procs

  # XXX: stub for reason, need to have ui to capture moderation reason
  command = req.body <<< {
    user_id: req.user.id
    post_id: req.params.id
    reason: \STUBBBBBB # XXX: fix me
  }

  (err, r) <- db.censor command
  if err then next err
  if r?success then c.invalidate-post req.params.id, req.user.name # blow cache!
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
    posts-per-page: posts-per-page
    meta-keywords:  "#{site.name}, PowerBulletin"
  fdoc.site.config = defaults <<< fdoc.site.config
  fdoc.site.config.analytics = escape(fdoc.site.config.analytics or '')
  fdoc.title = \Admin
  res.locals fdoc

  res.mutant \admin # out!

@search = (req, res, next) ->
  function cleanup-searchopts opts
    const key-blacklist =
      * \_surf
      * \_surfData
      * \_surfTasks

    opts = {} <<< opts

    for key in key-blacklist
      delete opts[key]

    opts


  site = res.vars.site

  err, menu <- db.menu res.vars.site.id
  if err then return next err

  err, elres, elres2 <- s.search req.query
  if err then return next(err)

  err, forum-dict <- db.forum-dict site.id
  if err then return next(err)

  res.locals.searchopts = cleanup-searchopts req.query

  for h in elres.hits
    h._source.posts = [] # stub object for non-existent sub-posts in search view

  facets = {forum: []}
  for t in elres2.facets.forum.terms
    forum_id  = t.term
    title     = forum-dict[forum_id]
    hit-count = add-commas t.count

    newopts = {} <<< res.locals.searchopts <<< {forum_id}
    delete newopts.page # resets to page 1 when filtering by a forum
    if qs = ["#{k}=#{encode-URI-component v}" for k,v of newopts].join \&
      uri = "/search?#{qs}"
    else
      uri = '/search'

    facets.forum.push {forum_id, title, uri, hit-count}

  res.locals {
    elres
    facets
    menu
    page: (req.query.page or '1')
    title: "Search#{if res.locals.searchopts.q then (' : ' + res.locals.searchopts.q) else ''}"
  }

  res.mutant \search

@page = (req, res, next) ->
  site = res.vars.site
  err, page <- db.pages.find-one criteria: { site_id: site.id, path: req.path }
  if err then return next err
  if page
    page.config = JSON.parse page.config
    tasks =
      menu: db.menu site.id, _
    if req.surfing
      delete tasks.menu
      delete-unnecessary-surf-data res
    err, fdoc <- async.auto tasks
    if err then return next err
    fdoc ||= {}
    fdoc.page = page
    res.locals fdoc
    res.mutant \page
  else
    next!

@checkout = (req, res, next) ->
  site-id    = res.vars.site.id
  product-id = req.params.product-id
  errors     = []

  err, existing-subscription <- db.subscriptions.find-one {
    criteria: {site_id: site-id, product_id: product-id}
    columns: [\product_id]
  }
  if err then return next err
  if existing-subscription then errors.push 'You\'re already subscribed'

  card = if req.body.number and req.body.expmo and req.body.expyear and req.body.code
    number:    req.body.number
    exp_month: req.body.expmo
    exp_year:  req.body.expyear
    cvc:       req.body.code
  else
    void

  finish = -> res.json {success:!errors.length, errors}
  if !errors.length
    err <- pay.subscribe {site-id, product-id, card}
    if err then errors.push err.message; console.log \card-error:, err
    if !errors.length then console.log \checkout, {site-id, product-id, card}
    finish!
  else
    finish!

# vim:fdm=indent
