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
  io-emitter: \socket.io-emitter
}

io = io-emitter!

global <<< require \./server-helpers
global <<< require \../shared/shared-helpers

{each} = require \prelude-ls
{is-editing, is-admin, is-auth} = require \./path-regexps
{title-case} = require \change-case # FIXME need custom title case routine: PowerBulletin -> PowerBulletin (not Powerbulletin)

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
  always-keep = <[ moderation_count summary subPostsCount tStep tQty ]>
  keep = always-keep ++ keep-string.split ','
  t = { [k, v] for k, v of tasks when k in keep }

@homepage = (req, res, next) ->
  # TODO fetch smart/fun combination of latest/best voted posts, posts & media
  site  = res.vars.site
  forum-ids = site.config.menu |> filter (-> it.form.dialog is \forum) |> map (-> it.form.dbid)
  tasks =
    #forums:  db.sites.thread-summary site.id, (req.query?order or \recent), 8, _
    summary: db.forums.forum-summary forum-ids, _

  err, doc <- async.auto tasks
  doc.menu            = site.config.menu
  doc.menu-summary    = site.config.menu
    |> map (item) -> # only top-level items
      decorate-menu-item {[k,v] for k,v of item when k isnt \children}, doc.summary
  doc.title           = title-case (res.vars.site?name or 'Power Bulletin Forum Communities in Real Time by Dimension Software')
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
    caching-strategies.etag res, sha1(JSON.stringify(__.clone(req.params) <<<  res.vars.site) + CHANGESET), 60s

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

    get-thread = (cb) ->
      if post.id is post.thread_id
        cb null, post
      else
        db.post site.id, post.thread_id, cb

    err, thread <- get-thread
    if err then return next err
    if !thread then return next 404

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
    if page > 1 and fdoc.sub-posts-tree?length < 1 then return next 404

    # attach sub-post to fdoc, among other things
    fdoc <<< {post, forum-id:post.forum_id, page, cvars.t-step}
    fdoc.item  = item
    fdoc.menu  = site.config.menu
    fdoc.title = title-case "#{post.title} | #{res.vars.site.name}"
    # attach sub-posts-tree to sub-post toplevel item
    fdoc.post.posts = delete fdoc.sub-posts-tree
    fdoc.qty = parse-int(delete fdoc.sub-posts-count)
    fdoc.limit = parse-int limit
    fdoc.pages-count = Math.ceil(fdoc.qty / fdoc.limit)
    fdoc.active-forum-id  = fdoc.post.forum_id
    fdoc.active-thread-id = thread.id
    fdoc.background       = background-for-forum fdoc.menu, fdoc.active-forum-id
    fdoc.commentable      = !!item?form?comments
    fdoc.thread           = thread

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
      summary     : db.forums.forum-summary forum-ids, _
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
    fdoc.title           = title-case "#{fdoc?forum?title} | #{res.vars.site?name}"
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
  unless item then return res.json 500, {-success} # guard
  # wipe file from disk
  err <- fs.unlink "public/sites/#{item.form.background.replace(/\?.*$/, '')}"
  if err then return res.json 500, {-success, msg:err}
  # update config
  path = menu.path-for-upsert m, item.id.to-string!
  item.form.background = void
  site.config.menu     = menu.struct-upsert m, path, item
  err, r <- db.site-update site # save!
  if err then return res.json 500, {-success, msg:err}
  res.json {+success}
  h.ban-all-domains site.id # blow cache since this affects html pages
@forum-background = (req, res, next) ->
  # get site
  site     = res.vars.site
  forum-id = parse-int req.params.id
  err, site <- db.site-by-id site.id
  if err then return next err
  err, file-name <- save-file-to-disk req.files.background, "#{site.id}", forum-id
  if err then return res.json 500, {-success, msg:"Unable to save file: #err"}
  if file-name
    # update site.config.menu
    m    = site.config.menu
    item = menu.flatten m |> find -> it.form.dbid is forum-id
    unless item then return res.json 500, {-success} # guard
    path = menu.path-for-upsert m, item.id.to-string!
    item.form.background = "#{site.id}/bg/#file-name?#{h.cache-buster!}".to-lower-case!
    site.config.menu     = menu.struct-upsert m, path, item

    err, r <- db.site-update site # save!
    if err then return res.json 500, {-success, msg:err}
    res.json {+success, background:item.form.background}
    h.ban-all-domains site.id # blow cache since this affects html pages
  else
    res.json 500, {-success, msg:'What kind of file is this?'}

@forum-logo-delete = (req, res, next) -> wipe-file-with-config res, \logo, next
@forum-logo = (req, res, next) ->
  site = res.vars.site
  err, site <- db.site-by-id site.id
  if err then return next err

  # html5-uploader (save forum logo)
  if logo = req.files?logo
    err, file-name <- save-file-to-disk req.files?logo, "#{site.id}", \logo
    if err then return res.json 500, {-success, msg:"Unable to save file: #err"}
    if file-name
      # update site.config
      site.config.logo = "#{site.id}/#file-name?#{h.cache-buster!}".to-lower-case!

      err, r <- db.site-update site # save!
      if err then return res.json 500, {-success, msg:err}
      res.json {+success, logo:site.config.logo}
      h.ban-all-domains site.id # blow cache since this affects html pages
    else
      res.json 500, {-success, msg:'What kind of file is this?'}
  else
    res.json 500, {-success, msg:'What logo?'}

@forum-header-delete = (req, res, next) -> wipe-file-with-config res, \header, next
@forum-header = (req, res, next) ->
  # get site
  site     = res.vars.site
  forum-id = parse-int req.params.id
  err, site <- db.site-by-id site.id
  if err then return next err
  err, file-name <- save-file-to-disk req.files.header, "#{site.id}", \header
  if err then return res.json 500, {-success, msg:"Unable to save file: #err"}
  if file-name
    # update site.config
    site.config.header = "#{site.id}/#file-name?#{h.cache-buster!}".to-lower-case!
    err, r <- db.site-update site # save!
    if err then return res.json 500, {-success, msg:err}
    res.json {+success, header:site.config.header}
    h.ban-all-domains site.id # blow cache since this affects html pages
  else
    res.json 500, {-success, msg:'What kind of file is this?'}

@private-background-delete = (req, res, next) -> wipe-file-with-config res, \privateBackground, next
@private-background = (req, res, next) ->
  # get site
  site     = res.vars.site
  err, site <- db.site-by-id site.id
  if err then return next err
  err, file-name <- save-file-to-disk req.files.background, "#{site.id}", \private-background
  if err then return res.json 500, {-success, msg:"Unable to save file: #err"}
  if file-name
    site.config.private-background = "#{site.id}/#file-name?#{h.cache-buster!}".to-lower-case!
    err, r <- db.site-update site # save!
    if err then return res.json 500, {-success, msg:err}
    res.json {+success, background:site.config.private-background}
  else
    res.json 500, {-success, msg:'What kind of file is this?'}

@offer-photo-delete = (req, res, next) ->
  #wipe-file-with-config res, \offer, next
  site = res.vars.site # get site
  err, site <- db.site-by-id site.id
  if err then return next err

  id = req.params.offerid
  err, page <- db.pages.select-one {id} # get offer (page)
  if err then return next err
  unless page then return res.json 500, {-success, msg:['Unable to find page']} # guard

  # update offer.config.offer-photo
  file-name = page.config.offer-photo?match(/offers\/(.+?)\?/).1

  # wipe file from disk
  if file-name
    unless file-name.to-string!match /\.\./ # guard
      err <- fs.unlink "public/sites/#{site.id}/offers/#file-name"
      if err then return res.json 500, {-success, msg:err}

      # update site.config.menu
      m    = site.config.menu
      item = menu.flatten m |> find -> it.form.dbid.to-string! is id
      unless item then return res.json 500, {-success, msg:'Unable to find page menu'} # guard
      delete item.form.offer-photo
      path = menu.path-for-upsert m, item.id.to-string!
      site.config.menu = menu.struct-upsert m, path, item
      err, r <- db.site-update site # save!

      # update page config
      cleanup-page-keys page
      delete page.config.offer-photo
      err <- db.pages.update-one page # save
      if err then return res.json 500, {-success, msg:err}
      res.json {+success}
      h.ban-all-domains site.id # blow cache since this affects html pages
    else
      res.json 500, {-success, msg:['Bad file name!']}
  else
    res.json 500, {-success, msg:['Unable to find file!']}
@offer-photo = (req, res, next) ->
  site = res.vars.site
  err, site <- db.site-by-id site.id
  if err then return next err

  # html5-uploader
  if offer-photo = req.files.offer-photo
    id = req.params.offerid
    # save offer-photo + menu id
    err, file-name <- save-file-to-disk offer-photo, "#{site.id}/offers", id
    if err then return res.json 500, {-success, msg:"Unable to save file: #err"}
    if file-name
      err, page <- db.pages.select-one {id} # get offer (page)
      if err then return next err
      if page
        # update offer.config.offer-photo
        offer-photo = page.config.offer-photo = "#{site.id}/offers/#file-name?#{h.cache-buster!}".to-lower-case!
        cleanup-page-keys page
        err <- db.pages.upsert page # save
        if err then return res.json 500, {-success, msg:err}

        # update site.config.menu
        m    = site.config.menu
        item = menu.flatten m |> find -> it.form.dbid.to-string! is id
        unless item then return res.json 500, {-success, msg:'Unable to find page menu'} # guard
        path = menu.path-for-upsert m, item.id.to-string!
        site.config.menu = menu.struct-upsert m, path, item
        err, r <- db.site-update site # save!

        res.json {+success, offer-photo}
        h.ban-all-domains site.id # blow cache since this affects html pages
      else
        res.json 500, {-success, msg:'Unable to find page'}
    else
      res.json 500, {-success, msg:'What kind of file is this?'}
  else
    res.json 500, {-success, msg:'What offer photo?'}

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
    res.json 500, {-success, errors}

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
  fdoc.title   = title-case "#name | #{res.vars.site?name}"
  fdoc.profile.human_post_count   = add-commas(fdoc.qty)
  fdoc.profile.human_thread_count = add-commas(fdoc.profile.thread_count) or 0

  res.locals fdoc
  res.locals.step = ppp

  # i know this is hacky, XXX use proper parsing later
  res.locals.uri = req.url
  res.locals.uri =
    res.locals.uri.replace /(_surf=[^&]*&?)|(_surfData=[^&]*&?)/, ''
  res.locals.uri =
    res.locals.uri.replace /\?$/, ''
  res.locals.limit = ppp

  # force comments ui on profile pages
  # - the post resource converts correctly to a reply if comments are disabled
  res.locals.commentable = true

  res.mutant \profile

function profile-paths user, uploaded-file, base=\avatar
  ext = uploaded-file.name.match(/\.(\w+)$/)?1 or ""
  r = {}
  r.avatar-file = if ext then "#base.#ext" else base
  r.url-dir-path = "/images/user/#{user.id}.#{user.site_id}"
  r.url-path = "#{r.url-dir-path}/#{r.avatar-file}"
  r.fs-dir-path = "public#{r.url-dir-path}"
  r.fs-path = "#{r.fs-dir-path}/#{r.avatar-file}"
  r

@profile-avatar = (req, res, next) ->
  db   = pg.procs
  user = req.user
  site = res.vars.site
  if not user
    return res.json { success: false, type: \not-logged-in }
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
  gm avatar.path # resolution guard
    .size (err, size) ->
      if err then return res.json {-success}
      console.log size
      if size.height < 200px or size.width < 200px
        return res.json 400, {-success, msg: 'Image must be at least 200x200px'}

      # mkdirp public/images/user/:user_id
      {avatar-file, url-dir-path, fs-dir-path, url-path, fs-path} = profile-paths user, avatar, \avatar-to-crop
      err <- mkdirp fs-dir-path
      if err
        console.error \mkdirp.rename, err
        return res.json { success: false, type: \mkdirp, path: fs-dir-path }

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
    .resize 200px, 200px
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
        io.in(site.id).emit \new-profile-photo, { id: user.id, photo: new-photo }
        ban-all-domains site.id
        return res.json success: true
  res.json success: false

@stylus = (req, res, next) ->
  site = res.vars.site
  r = req.route.params
  files = r.file.split ','
  if not files?length then return next 404

  render-css = render-css-fn define: [ [ \site-id, site.id ] ]

  async.map files, render-css, (err, css-blocks) ->
    if err
      return next 404
    body = css-blocks.join "\n"
    caching-strategies.etag res, sha1(body + CHANGESET), 7200
    res.content-type \css
    res.send body

@add-impression = (req, res, next) ->
  db = pg.procs
  (err, r) <- db.add-thread-impression req.params.id
  if err then next err
  site = res.vars.site
  # TODO make add-thread-impression return forum_id
  # TODO make room name based on site.id and forum_id
  io.in(site.id).emit \thread-impression r #{ id: req.params.id, views: r.views, forum_id: r.thread_id }
  res.json success: true

@censor = (req, res, next) ->
  return next 404 unless req.user
  db = pg.procs

  # XXX: stub for reason, need to have ui to capture moderation reason
  command = req.body <<< {
    user_id: req.user.id
    post_id: req.params.id
  }

  (err, r) <- db.censor command
  if err then next err
  if r?success then c.invalidate-post req.params.id, req.user.name # blow cache!
  res.json r

@uncensor = (req, res, next) ->
  return next 404 unless req.user
  db = pg.procs
  command = req.body <<< {
    user_id: req.user.id
    post_id: req.params.id
  }
  (err, r) <- db.posts.uncensor command
  if err then next err
  c.invalidate-post req.params.id, req.user.name # blow cache!
  res.json {+success}

@sticky = (req, res, next) ->
  return next 404 unless req.user
  return next 403 unless req.user.sys_rights?super or req.user.rights?super
  site = res.vars.site
  thread-id = req.params.id

  err, r <- db.posts.toggle-sticky thread-id
  if err then return next err

  new-sticky-state =
    success : true
    sticky  : !!r.is_sticky

  h.ban-all-domains site.id
  res.json new-sticky-state

@locked = (req, res, next) ->
  return next 404 unless req.user
  return next 403 unless req.user.sys_rights?super or req.user.rights?super
  site = res.vars.site
  thread-id = req.params.id

  err, r <- db.posts.toggle-locked thread-id
  if err then return next err

  new-locked-state =
    success : true
    locked  : !!r.is_locked

  h.ban-all-domains site.id
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
    * id:0 name:'PowerBulletin'
    * id:1 name:'Autumn'
    * id:2 name:'Spring'
    * id:3 name:'Winter'
    * id:4 name:'Fall'
    * id:5 name:'Summer'
    * id:6 name:'Monsoon'
  defaults =
    posts-per-page: site.config?posts-per-page or posts-per-page
    meta-keywords:  "#{site.name}, PowerBulletin"
  fdoc.site.config = defaults <<< fdoc.site.config
  fdoc.site.config.analytics = escape(fdoc.site.config.analytics or '')
  fdoc.title = "Admin | #{res.vars.site.name}"
  fdoc.menu  = site.config.menu

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
    item = fdoc.menu |> find -> it.form.dialog in <[page offer]> and it.form.dbid is page.id
    fdoc.site-name       = site.name
    fdoc.title           = title-case (page.title or 'Power Bulletin Forum Communities in Real Time by Dimension Software')
    fdoc.page            = page
    fdoc.newsletter      = site.config.newsletter
    fdoc.active-forum-id = page.id
    fdoc.content-only    = item?form?content-only is \checked
    res.locals fdoc
    caching-strategies.etag res, sha1((JSON.stringify page.config) + CHANGESET), 60s
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
        item.thread_count = (add-commas forum.thread_count) or 0
        item.post_count   = (add-commas forum.post_count) or 0
        item.latest_post  =
          html:     forum.last_post_html
          title:    title-case (forum?last_post_title or '')
          uri:      forum.last_post_uri
          username: forum.last_post_user_name
          photo:    forum.last_post_user_photo
          user_id:  forum.last_post_user_id
          created:  add-dates forum, [ \last_post_created ]
  item

function extention-for file-name
  file-name?match(/\.(\w+)$/)?1 or ""

function save-file-to-disk file, dst-dir, dst-file-name, cb
  # html5-uploader (save forum backgrounds)
  # mkdirp public/sites/ID
  const prefix = \public/sites
  err <- mkdirp "#prefix/#dst-dir"
  if err then return cb err

  # atomic write to public/sites/SITE-ID/bg/FORUM-ID.jpg
  ext = extention-for file.name
  file-name = if ext then "#dst-file-name.#ext" else dst-file-name
  err <- move file.path, "#prefix/#dst-dir/#file-name".to-lower-case!
  if err then return cb err
  cb null, file-name

function wipe-file-with-config res, key, next
  site = res.vars.site # get site
  err, site <- db.site-by-id site.id
  if err then return next err

  # wipe file from disk
  if file-name = site.config[key]
    unless (file-name is \powerbulletin_header.jpg) or (file-name.to-string!match /\.\./) # guard
      err <- fs.unlink "public/sites/#{file-name.replace(/\?.*$/, '')}"
      if err then return res.json 500, {-success, msg:err}

    # update config
    site.config[key] = ''
    err, r <- db.site-update site # save!
    if err then return res.json 500, {-success, msg:err}
    res.json {+success}
  else
    res.json 500, {-success, msg:['Unable to find file!']}
  h.ban-all-domains site.id # blow cache since this affects html pages

function cleanup-page-keys page # XXX mutates
  unless page then return # guard
  for k in <[created_human created_iso created_friendly updated_human updated_iso updated_friendly]>
    delete page[k] # prune these before updating
  page
# vim:fdm=indent
