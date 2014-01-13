require! {
  fs
  async
  jade
  mkdirp
  querystring
  gm
  s: \./search
  c: \./cache
  h: \./server-helpers
  __:   \lodash
  pg:   \./postgres
  auth: \./auth
  furl: \../shared/forum-urls
  pay: \./payments
  \./menu
  url
  sch: \./sales-component-handlers
}

announce = require(\socket.io-announce).create-client!

global <<< require \./server-helpers
global <<< require \../shared/shared-helpers

{each} = require \prelude-ls
{is-editing, is-admin, is-auth} = require \./path-regexps

const posts-per-page = 30

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
     \style
     \analytics
     \inviteOnly
     \cache2Url # keeping cacheUrl
     \cache3Url
     \cache4Url
     \cache5Url
     \jsUrls
     \cssUrls
     \menu
  for i in unnecessary
    delete locals[i]
  locals

# remove tasks that don't have to be run when surfing
# @param Object tasks         hashmap of tasks to be given to async.auto
# @param String keep-string   comma-separated list of tasks to be kept
# @returns Object             a new, smaller set of tasks
delete-unnecessary-surf-tasks = (tasks, keep-string) ->
  always-keep = <[ summary subPostsCount tStep tQty ]>
  keep = always-keep ++ keep-string.split ','
  t = { [k, v] for k, v of tasks when k in keep }

@homepage = (req, res, next) ->
  # TODO fetch smart/fun combination of latest/best voted posts, posts & media
  site  = res.vars.site
  tasks =
    #forums:  db.sites.thread-summary site.id, (req.query?order or \recent), 8, _
    summary: db.sites.forum-summary site.id, _

  err, doc <- async.auto tasks
  doc.menu            = site.config.menu
  doc.menu-summary    = site.config.menu
    |> map (item) -> # only top-level items
      decorate-menu-item {[k,v] for k,v of item when k isnt \children}, doc.summary
  doc.title           = res.vars.site.name
  doc.description     = ''
  doc.active-forum-id = \homepage

  if req.surfing then delete-unnecessary-surf-data res

  res.locals doc

  # XXX: this should be abstracted into a pattern, middleware or pure function
  # cache homepage for 60s
  if res.locals.private
    # make sure private sites aren't cached
    caching-strategies.nocache res
  else
    # only cache if not a private site, private sites must never be cached
    caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<<  res.vars.site), 60s

  res.content-type \html
  res.mutant \homepage

# returns forum background
function background-for-forum m, active-forum-id
  return unless m?length # guard
  item = menu.flatten m |> find -> it.form.dbid is active-forum-id
  item?form?background

@forum = (req, res, next) ->
  user = req.user
  uri  = req.path

  meta = furl.parse querystring.unescape(req.path)
  #console.warn meta.type, meta.path
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
    caching-strategies.nocache res # we never cache forum pages upstream because they are live
    unless res.locals.private
      # only cache if not a private site, private sites must never be cached
      res.header \x-varnish-ttl \24h # we cache for a very long ttl in varnish because we control this cache

    if req.surfing then delete-unnecessary-surf-data res
    res.mutant \forum

  if meta.type is \moderation
    tasks =
      forum-id: db.uri-to-forum-id res.vars.site.id, meta.forum-uri, _
      posts: [\forumId, (cb, a) -> db.posts.moderated(a.forum-id, cb)]

    err, fdoc <- async.auto tasks
    if err then return next err
    fdoc.menu = site.config.menu

    res.locals fdoc
    caching-strategies.nocache res
    res.mutant \moderation
    return

  else if post_part # thread view
    err, post <- db.uri-to-post site.id, meta.thread-uri
    if err then return next err
    if !post then return next 404

    page = meta.page || 1
    if page < 1 then return next 404

    # fetch forum settings
    item   = menu.flatten site.config.menu |> find -> it.form.dbid is post.forum_id
    limit  = item?form?posts-per-page or posts-per-page
    offset = (page - 1) * limit

    tasks =
      sub-posts-tree  : db.sub-posts-tree site.id, post.id, 'p.*', limit, offset, _
      sub-posts-count : db.sub-posts-count post.id, _
      top-threads     : db.top-threads site.id, post.forum_id, \recent, cvars.t-step, 0, _ # always offset 0 since thread pagination is ephemeral
      t-qty           : db.thread-qty post.forum_id, _
      forum           : db.forum post.forum_id, _

    if req.surfing
      delete-unnecessary-surf-data res
      if req.query._surf-tasks
        tasks = delete-unnecessary-surf-tasks tasks, req.query._surf-tasks
      else
        delete tasks.menu

    err, fdoc <- async.auto tasks
    #console.warn err, keys(fdoc)
    if err   then return next err
    if !fdoc then return next 404
    if page > 1 and fdoc.sub-posts-tree.length < 1 then return next 404

    # attach sub-post to fdoc, among other things
    fdoc <<< {post, forum-id:post.forum_id, page, cvars.t-step}
    fdoc.item  = item
    fdoc.menu  = site.config.menu
    fdoc.title = "#{res.vars.site.name} - #{post.title}"
    # attach sub-posts-tree to sub-post toplevel item
    fdoc.post.posts = delete fdoc.sub-posts-tree
    fdoc.qty = parse-int(delete fdoc.sub-posts-count)
    fdoc.limit = parse-int limit
    fdoc.pages-count = Math.ceil(fdoc.qty / fdoc.limit)
    fdoc.active-forum-id  = fdoc.post.forum_id
    fdoc.active-thread-id = post.id
    fdoc.background       = background-for-forum fdoc.menu, fdoc.active-forum-id

    finish fdoc

  else # forum & forum homepage
    err, forum-id <- db.uri-to-forum-id res.vars.site.id, meta.forum-uri
    if err then return next err
    if !forum-id then return next 404

    # get active menu item
    m        = site.config.menu
    item     = menu.flatten m |> find -> it.form.dbid is forum-id
    children = (menu.item m, (menu.path m, item?id))?children or []
    forum-ids = children |> map (.form.dbid) |> filter (-> it)

    tasks =
      #forums      : db.forums.thread-summary site.id, forum-ids, (req.query?order or \recent), 8, _
      summary     : db.forums.forum-summary site.id, forum-ids, _
      forum       : db.forum forum-id, _
      top-threads : db.top-threads site.id, forum-id, \recent, cvars.t-step, 0, _ # always offset 0 since thread pagination is ephemeral
      t-qty       : db.thread-qty forum-id, _

    if req.surfing
      if req.query._surf-tasks
        tasks = delete-unnecessary-surf-tasks tasks, req.query._surf-tasks
      else
        delete tasks.menu

    err, fdoc <- async.auto tasks
    if err then return next err
    if !fdoc then return next 404

    fdoc <<< {forum-id, cvars.t-step}
    fdoc.item            = item
    fdoc.menu            = m
    fdoc.menu-summary    = children
      |> map (child) -> # only top-level
        decorate-menu-item {[k,v] for k,v of child when k isnt \children}, fdoc.summary
    fdoc.active-forum-id = fdoc.forum-id
    fdoc.title           = "#{res.vars.site.name} - #{fdoc?forum?title}"
    fdoc.description     = item?form?forum-description or ''
    fdoc.background      = background-for-forum fdoc.menu, fdoc.active-forum-id

    finish fdoc

@forum-background-delete = (req, res, next) ->
  # get site
  site = res.vars.site
  err, site <- db.site-by-id site.id
  if err then return next err
  forum-id  = parse-int req.params.id
  # get item
  m    = site.config.menu
  item = menu.flatten m |> find -> it.form.dbid is forum-id
  unless item then return res.json {-success} # guard
  # wipe file from disk
  err <- fs.unlink "public/sites/#{item.form.background.replace(/\?.*$/, '')}"
  if err then return res.json {-success, msg:err}
  # update config
  path = menu.path-for-upsert m, item.id.to-string!
  item.form.background = void
  site.config.menu     = menu.struct-upsert m, path, item
  err, r <- db.site-update site # save!
  if err then return res.json {-success, msg:err}
  res.json {+success}

@forum-background = (req, res, next) ->
  # get site
  site = res.vars.site
  err, site <- db.site-by-id site.id
  if err then return next err

  # html5-uploader (save forum backgrounds)
  background = req.files.background

  # mkdirp public/sites/ID
  dst = "public/sites/#{site.id}/bg"
  err <- mkdirp dst
  if err then return res.json {-success, msg:err}

  # atomic write to public/sites/SITE-ID/bg/FORUM-ID.jpg
  forum-id  = parse-int req.params.id
  ext       = background.name.match(/\.(\w+)$/)?1 or ""
  file-name = if ext then "#forum-id.#ext" else forum-id
  err <- move background.path, "#dst/#file-name".to-lower-case!
  if err then return res.json {-success, msg:err}

  # update site.config.menu
  m    = site.config.menu
  item = menu.flatten m |> find -> it.form.dbid is forum-id
  unless item then return res.json {-success} # guard
  path = menu.path-for-upsert m, item.id.to-string!
  item.form.background = "#{site.id}/bg/#file-name?#{h.cache-buster!}".to-lower-case!
  site.config.menu     = menu.struct-upsert m, path, item

  err, r <- db.site-update site # save!
  if err then return res.json {-success, msg:err}
  res.json {+success, background:item.form.background}

# user profiles /user/:name
@profile = (req, res, next) ->
  db   = pg.procs
  site = res.vars.site
  name = req.params.name
  page = req.params.page or 1
  ppp  = site.config?posts-per-page or posts-per-page
  usr  = { name: name, site_id: site.id }

  if req.params.page
    req.assert(\page, 'Invalid page number').is-int!

  errors = req.validation-errors!
  if errors
    err = new Error errors.0?msg
    err.non-fatal = true
    return next err

  tasks =
    profile        : db.usr usr, _
    posts-by-user  : db.posts-by-user usr, page, ppp, _
    qty            : [\profile, (cb, a) ->
      if not a.profile
        cb 404
      else
        db.posts-count-by-user(a.profile, cb)
    ]
    pages-count    : db.posts-by-user-pages-count usr, ppp, _

  if req.surfing then delete-unnecessary-surf-data res

  err, fdoc <- async.auto tasks
  unless fdoc.profile then return next 404 # guard
  fdoc.profile = add-dates fdoc.profile, [ \last_activity ]
  fdoc.furl    = thread-uri: "/user/#name" # XXX - a hack to fix the pager that must go away
  fdoc.menu    = site.config.menu
  fdoc.page    = parse-int page
  fdoc.title   = "#{res.vars.site.name} - #name"
  fdoc.profile.human_post_count   = add-commas(fdoc.qty)
  fdoc.profile.human_thread_count = add-commas(fdoc.profile.thread_count)

  res.locals fdoc
  res.locals.step = ppp

  # i know this is hacky, XXX use proper parsing later
  res.locals.uri = req.url
  res.locals.uri =
    res.locals.uri.replace /(_surf=[^&]*&?)|(_surfData=[^&]*&?)/, ''
  res.locals.uri =
    res.locals.uri.replace /\?$/, ''
  res.locals.limit = ppp

  res.mutant \profile

function profile-paths user, uploaded-file, base=\avatar
  ext = uploaded-file.name.match(/\.(\w+)$/)?1 or ""
  r = {}
  r.avatar-file = if ext then "#base.#ext" else base
  r.url-dir-path = "/images/user/#{user.id}"
  r.url-path = "#{r.url-dir-path}/#{r.avatar-file}"
  r.fs-dir-path = "public#{r.url-dir-path}"
  r.fs-path = "#{r.fs-dir-path}/#{r.avatar-file}"
  r

@profile-avatar = (req, res, next) ->
  db   = pg.procs
  user = req.user
  site = res.vars.site
  console.warn \lookup-user, { id: req.params.id, site_id: site.id }
  err, usr <- db.usr { id: req.params.id, site_id: site.id }
  console.warn \found-user, err, usr
  console.warn \logged-in-as, user
  if err
    console.error \db.usr
    return res.json { success: false, type: \db.usr }
  if usr.name != user.name
    console.error \authorization, "#{usr.name} != #{user.name}"
    return res.json { success: false, type: \authorization }

  avatar = req.files.avatar
  #console.warn \avatar, avatar

  # mkdirp public/images/user/:user_id
  {avatar-file, url-dir-path, fs-dir-path, url-path, fs-path} = profile-paths user, avatar, \avatar-to-crop
  err <- mkdirp fs-dir-path
  if err
    console.error \mkdirp.rename, err
    return res.json { success: false, type: \mkdirp }

  # move image to public/images/user/:user_id/
  err <- move avatar.path, fs-path
  if err
    console.error \move, err
    return res.json { success: false, type: \move }

  # update user avatar
  #err, success <- db.change-avatar user, "#url-path?#{cache-buster!}"
  #if err
  #  console.error \change-avatar, err
  #  return res.json { success: false, type: \db.change-avatar }
  res.json success: true, url: url-path

@profile-avatar-crop = (req, res, next) ->
  user = req.user
  site = res.vars.site
  {x,y,x1,y1,w,h,path} = req.body
  # TODO - sanity check on path to prevent pwnage
  if not path
    return res.json success: false, type: \no-path
  if path.match /\.\./
    return res.json success: false, type: \no-relative-paths-allowed
  r = path.match /^\/images\/user\/(\d+)/
  # sanity check on r, too
  _crop   = name: path
  _avatar = name: path.replace /-to-crop/, ''
  cropped-photo = profile-paths req.user, _crop, \avatar-to-crop
  avatar-photo  = profile-paths req.user, _avatar
  console.warn \crop, { cropped-photo, avatar-photo }
  gm(cropped-photo.fs-path)
    .crop w, h, x, y
    .resize 255, 255
    .write avatar-photo.fs-path, (err) ->
      if err
        console.warn \crop-and-resize-err, err
        res.json success: false
      else
        new-photo = "#{avatar-photo.url-path}?#{cache-buster!}"
        err <- db.change-avatar user, new-photo
        if err
          console.error \change-avatar, err
          return res.json success: false, type: \db.change-avatar
        announce.in(site.id).emit \new-profile-photo, { id: user.id, photo: new-photo }
        return res.json success: true
  res.json success: false

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

@sticky = (req, res, next) ->
  return next 404 unless req.user
  return next 403 unless req.user.sys_rights?super or req.user.rights?super
  thread-id = req.params.id

  err, r <- db.posts.toggle-sticky thread-id
  if err then return next err

  new-sticky-state =
    success : true
    sticky  : !!r.is_sticky

  res.json new-sticky-state

@locked = (req, res, next) ->
  return next 404 unless req.user
  return next 403 unless req.user.sys_rights?super or req.user.rights?super
  thread-id = req.params.id

  err, r <- db.posts.toggle-locked thread-id
  if err then return next err

  new-locked-state =
    success : true
    locked  : !!r.is_locked

  res.json new-locked-state

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

  user = req.user
  tasks =
    site: db.site-by-id site.id, _
    sites: db.sites.owned-by-user user.id, _

  if req.surfing
    delete-unnecessary-surf-data res

  err, fdoc <- async.auto tasks
  if err then return next err

  # default
  fdoc.themes =
    * id:1 name:'PowerBulletin Minimal'
    * id:0 name:\None
  defaults =
    posts-per-page: site.config?posts-per-page or posts-per-page
    meta-keywords:  "#{site.name}, PowerBulletin"
  fdoc.site.config = defaults <<< fdoc.site.config
  fdoc.site.config.analytics = escape(fdoc.site.config.analytics or '')
  fdoc.title   = "#{res.vars.site.name} - Admin"
  fdoc.menu = site.config.menu

  # reject current site
  tmp = fdoc.sites |> reject (.id is site.id)
  fdoc.sites = tmp # mutate

  res.locals fdoc

  if res.locals.action is \users
    # populate user info into locals
    # XXX this shares namespace with other mutant admin locals so this code needs to be treaded on very carefully
    # ideally in the future we won't be using the mutant system in the same namespace or the whole mutant forum app
    # will be encapsulated into its own Component
    err <- sch.super-users req, res
    if err then return next err
    res.mutant \admin # out!
  else
    # default
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
  searchopts = {} <<< req.query <<< {site_id: site.id}
  console.warn searchopts

  err, elres, elres2 <- s.search searchopts
  if err then return next(err)

  err, forum-dict <- db.forum-dict site.id
  if err then return next(err)

  res.locals {searchopts: cleanup-searchopts(searchopts)}

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

  function compare-title o1, o2
    if o1.title > o2.title
      1
    else if o1.title is o2.title
      0
    else
      -1

  res.locals {
    elres
    facets
    forums-alphabetized: [{id: k, title: v} for k,v of forum-dict].sort compare-title
    menu:  site.config.menu
    page: (req.query.page or '1')
    title: "Search#{if res.locals.searchopts.q then (' : ' + res.locals.searchopts.q) else ''}"
  }

  # NOTE: not sure if caching is possible given the dynamicness of
  # search queries
  # how do we know when to blow the cache? it is difficult...
  #
  # try to rely instead on the internal elastic caching mechanisms
  # which allow you to cache certain fragments of the query ??
  caching-strategies.nocache res # updates happen in realtime

  res.mutant \search

@page = (req, res, next) ->
  site = res.vars.site
  err, page <- db.pages.select-one { site_id: site.id, path: req.path }
  if err then return next err
  if page
    if req.surfing then delete-unnecessary-surf-data res
    fdoc ||= {}
    fdoc.menu = site.config.menu
    item = fdoc.menu |> find -> it.form.dialog is \page and it.form.dbid is page.id
    fdoc.page            = page
    fdoc.active-forum-id = page.id
    fdoc.content-only    = item?form?content-only is \checked
    res.locals fdoc
    caching-strategies.etag res, sha1(JSON.stringify page.config), 60s
    res.mutant \page
  else
    next!

@checkout = (req, res, next) ->
  site-id    = res.vars.site.id
  product-id = req.params.product-id
  errors     = []

  err, existing-subscription <- db.subscriptions.select-one {site_id: site-id, product_id: product-id}
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

function decorate-menu-item item, forums
  switch item.form.dialog
  | \forum =>
    if forums?length # match menu w/ forum data
      forum = forums |> find -> it.id is item.form.dbid
      if forum
        item.thread_count = add-commas forum.thread_count
        item.post_count   = add-commas forum.post_count
        item.latest_post  =
          html:     forum.last_html
          created:  forum.last_post_created
          username: forum.last_post_name
          user_id:  forum.last_post_user_id
  item

# vim:fdm=indent
