require! {
  pg: \./postgres
  v: \./varnish
  c: \./cache
  h: \./server-helpers
  sioa: \socket.io-announce
  auth: \./auth
  menu: \./menu
  rights: \./rights
  async
  fs
  mkdirp
  stylus
  pagedown
  \deep-equal
}

const base-css = \public/sites

announce = sioa.create-client!

# Return true if forum-id is a locked forum according to the menu m.
is-locked-forum = (m, forum-id) ->
  menu.flatten(m) |> find (-> f = it.form; f.dialog is \forum and f.dbid is forum-id and f.locked)

# cb(null, true) if current thread is locked
is-locked-thread-by-parent-id = (parent-id, cb) ->
  return cb(null, false) if not parent-id
  err, r <- db.posts.is-thread-locked parent-id
  if err then return cb err
  cb null, r.is_locked

@aliases =
  update: (req, res, next) ->
    site_id = req.user?site_id # only allow updating on auth'd site
    user_id = req.params.alias
    (err, r) <- rights.can-edit-user req.user, user_id
    if err then return next err
    if r # can edit, so--
      (err, alias) <- db.aliases.select-one {user_id, site_id}  # fetch current config
      c = new pagedown.Converter
      config={}
      alias.config <<< req.body?config or {}                      # & merge
      alias.config.sig = req.body.editor                          # merge from Editor
      for k in <[title sig]> then config[k]=alias.config[k]       # & scrub
      if config.sig then config.sig-html = c.make-html config.sig # & scrub harder + render sig
      err <- db.aliases.update {config}, {user_id, site_id}       # & update!
      announce.in(site_id).emit \new-profile-title, { id:user_id, title:config?title } # broadcast title everywhere
      (err, user) <~ db.usr { id:user_id, site_id }
      user.sig = config.sig # ensure latest sig
      delete user.auths
      announce.in("#site_id/users/#user_id").emit \set-user, user # brodcast new user object to all of my browsers
      res.json {+success}
    else
      res.json {-success}

@sites =
  create: (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard

    # get site
    site = res.vars.site
    err, site <- db.site-by-id site.id
    if err then return next err

    # TODO /icanhazsite
    res.json {-success}

  update: (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard

    # get site
    site = res.vars.site
    err, site <- db.site-by-id site.id
    if err then return next err

    # save site
    switch req.body.action
    | \general =>
      should-ban = false # varnish
      for f in [\style \postsPerPage \inviteOnly \private \social \analytics]
        if site.config[f] isnt req.body[f] then should-ban = true

      css-dir = "#base-css/#{site.id}"
      # save css to disk for site
      if site.config.style isnt req.body.style # only on change
        site.config.cache-buster = h.cache-buster!
        err <- db.sites.save-style site
        if err
          if err?msg?match /CSS/i
            return res.json {success:false, messages:['CSS must be valid!']}
          else
            return next err

      # save color theme
      if not deep-equal(site.config.color-theme, req.body.color-theme)
        err <- db.sites.save-color-theme { id: site.id, config: { color-theme: req.body.color-theme } }
        announce.in("#{site.id}/users/#{req.user.id}").emit \css-update, req.body.color-theme
        if err then res.json { -success, messages: [ "Could not save color theme." ] }

      # update site
      site.name = req.body.name
      site.config <<< { [k, val] for k, val of req.body when k in # guard
        <[ postsPerPage metaKeywords inviteOnly private social analytics style colorTheme ]> }
      for c in <[ inviteOnly  social private ]> # uncheck checkboxes?
        delete site.config[c] unless req.body[c]
      for s in <[ private analytics ]> # subscription tampering
        delete site.config[s] unless s in site.subscriptions
      err, r <- db.site-update site # save!
      if err then return next err

      # save domains
      err, domain <- db.domain-by-id req.body.domain
      if err then return next err

      # does site own domain?
      err, domains <- db.domains-by-site-id domain.site_id
      if err then return next err
      unless find (.site_id is domain.site_id) domains then return next 404

      # extract specific keys
      auths = [
        \facebookClientId
        \facebookClientSecret
        \twitterConsumerKey
        \twitterConsumerSecret
        \googleConsumerKey
        \googleConsumerSecret]
      domain.config <<< { [k, v] for k, v of req.body when k in auths}

      # save domain config
      const suffix = \Secret
      domain.config.style = auths
        |> filter (-> it.index-of(suffix) isnt -1 and req.body[it])                # only auths with values
        |> map (-> ".has-#{take-while (-> it in [\a to \z]), it}{display:inline}") # make css selectors
        |> join ''
      if domain.config.style.length then domain.config.style += '.has-auth{display:block}'
      err, r <- db.domain-update domain # save!
      if err then return next err

      # delete existing passport for domain so new one can be created
      delete auth.passports[domain.name]

      # save css to disk
      css-dir = "#base-css/#{domain.site_id}"
      err <- mkdirp css-dir
      if err then return next err
      err <- fs.write-file "#css-dir/#{domain.id}.auth.css" domain.config.style

      # varnish ban
      h.ban-all-domains site.id if should-ban
      res.json success:true

    | \menu =>
      # save site config
      m    = site.config?menu or []
      id   = req.body.id.to-string! # client-id
      dbid = null # server-id

      if id # active form
        form = { [k, v] for k,v of req.body when k in
          <[ id dbid title placeholderDescription linkDescription forumDescription pageDescription dialog postsPerPage forumSlug locked comments pageSlug content url contentOnly separateTab ]> }
        menu-item = { id, form.title, form }
        menu-item = { id, form.title, form }
        m-path = menu.path-for-upsert m, id
        site.config.menu = menu.struct-upsert m, m-path, menu-item

      err, r <- menu.db-upsert site, menu-item
      return res.json {-success, errors: err?errors} if err?errors

      if err then return res.json success: false, hint: \menu.upsert, err: err, errors: [ err.message ]
      if r.length
        menu-item.form.dbid = dbid = r.0.id
        m2 = site.config.menu
        site.config.menu = menu.struct-upsert m2, m-path, menu-item

      err, r <- db.site-update site
      if err then return res.json success: false, hint: \db.site-update

      h.ban-all-domains site.id # varnish ban
      announce.in(site.id).emit \menu-update, site.config.menu
      res.json success:true, id: dbid

    # delete a menu
    | \menu-delete =>
      id  = req.body.id
      m   = site.config.menu
      src = menu.path m, id
      if src is false
        return res.json success: false

      item     = menu.item m, src
      new-menu = menu.delete m, src

      # delete menu item and its children from database
      del = (item, cb) -> menu.db-delete item, cb
      err <- async.each menu.flatten([item]).reverse!, del
      if err then return res.json success: false, hint: \menu-db-delete, err: err, errors: [ "Item could not be deleted." ]

      site.config.menu = new-menu
      err, r <- db.site-update site
      if err then return res.json success: false, hint: \db-site-update, err: err, errors: [ "Item could not be deleted." ]

      h.ban-all-domains site.id # varnish ban
      announce.in(site.id).emit \menu-update, site.config.menu
      res.json success: true

    # resort a menu
    | \menu-resort =>
      id   = req.body.id
      tree = JSON.parse req.body.tree
      src  = menu.path site.config.menu, id
      dst  = menu.path tree, id
      if dst is false or src is false
        return res.json success:false

      new-menu = menu.move site.config.menu, src, dst
      site.config.menu = new-menu
      err, r <- db.site-update site
      if err then return res.json success: false, hint: \menu-resort

      h.ban-all-domains site.id # varnish ban
      announce.in(site.id).emit \menu-update, site.config.menu
      res.json success:true

@users =
  create : (req, res, next) ->
    user   = req.user
    site   = res.vars.site
    emails = req.body.emails.to-string!

    # guards
    if not user?rights?super then return next 404
    if not emails.length then return res.json {success:false, msg:'Who to invite?'}
    emails = emails.split ','

    # generate new users + email w/ inbound verify-&-choose-user-name link
    switch req.body.action
    | \invites =>
      register = (email, cb) ->
        (err, new-user) <- register-local-user site, email, email, email
        u = if err?name then err else new-user
        if err and !u
          cb err
        else # resend email if already registered
          if u.verify then
            auth.send-invite-email site, user, u, req.body.message
            cb(if err then "Re-invited #{u.name}" else null)
          else
            cb "#{u.name} is registered!"

      (err, r) <- async.each emails, register
      if err then return res.json {success:false, msg:err}
      res.json success:true

    | otherwise =>
      user = req.params.user
      # munge data
      (err, user) <- db.find-or-create user
      res.json user
  update: (req, res, next) ->
    # RIGHTS: can only edit users on sites you are an admin of
    admin = req.user
    site  = res.vars.site
    id    = req.params.user
    err, can-edit-user <- rights.can-edit-user admin, id
    if err
      return next err
    if not can-edit-user
      return res.json success: false, errors: [ "#{admin.name} may not edit this user." ]

    user = {} <<< req.body <<< {id}
    console.warn \STUB, 'handle user PUT from UserEditor'
    console.warn \STUBUSER, user

    alias =
      name    : user.name
      user_id : id
      site_id : site.id

    err, new-alias <- db.aliases.update alias
    if err
      res.json success: false, errors: [ 'Unable to save User' ]
    else
      res.json success: true, alias: new-alias

@domains =
  create: (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard

    # get site
    site = res.vars.site
    err, site <- db.site-by-id site.id
    if err then return next err

    unless \custom_domain in site.subscriptions # prevent tampering
      res.json {success:false, errors:['Subscribe to custom domain first']}
      return false

    # add domain
    # TODO validation
    err, r <- db.domains.upsert {site_id:site.id, name:req.body.name}
    if err then res.json success:false, errors:['Domain in use']
    res.json {success:true, domain:r.0}

@posts =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.locals.pid = req.query.pid
    res.render \post-new
  create  : (req, res, next) ->
    return next 404 unless req.user
    site = res.vars.site
    db = pg.procs
    post          = req.body
    post.user_id  = req.user.id
    post.html     = h.html post.body
    post.ip       = res.vars.remote-ip
    post.tags     = h.hash-tags post.body

    return res.json success:false, errors:['Incomplete post'] unless post.user_id and post.forum_id # guard

    if is-locked-forum(site.config.menu, parse-int(post.forum_id)) and (not req.user.rights?super)
      return res.json success: false, errors: [ "The forum is locked." ]

    err, is-locked-thread <- is-locked-thread-by-parent-id (parse-int post.parent_id or 0)
    if err then return next err
    if is-locked-thread and not (req.user?rights?super or req?user?sys_rights?super)
      return res.json success: false, errors: [ "This thread is locked." ]

    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      post.id = ap-res.id
      c.invalidate-post post.id, req.user.name # blow cache!

    unless post.parent_id
      err, new-post <- db.post site.id, post.id
      if err then return next err
      announce.in(site.id).emit \thread-create new-post
      db.thread_subscriptions.add(site.id, req.user.id, new-post.thread_id)
    else
      err, new-post <- db.post site.id, post.id
      if err then return next err
      new-post.posts = []
      announce.in(site.id).emit \post-create new-post
      db.thread_subscriptions.add(site.id, req.user.id, new-post.thread_id)

    res.json ap-res
  show    : (req, res, next) ->
    site = res.vars.site
    db = pg.procs
    if post-id = parse-int(req.params.post)
      err, post <- db.post site.id, post-id
      if err then return next err
      res.json post
    else
      return next 404
  update  : (req, res, next) ->
    # if not req?user?rights?super then return next 404 # guard
    # is_owner req?user
    err, owns-post <- db.owns-post parse-int(req.body.id), req.user?id
    if err then return next err
    return next 403 unless (req?user?rights?super) or (owns-post?length and owns-post.0.forum_id)
    # TODO secure & csrf
    # save post
    unless op = owns-post?0 then return res.json {-success, errors:["You don't own this post"]}
    post           = req.body
    post.user_id   = req.user.id
    post.forum_id  = op.forum_id
    post.parent_id = op.parent_id
    post.title     = h.html req.body.title
    post.html      = h.html req.body.body
    err, r <- db.edit-post(req.user, post)
    if err then return next err

    if r.success
      # blow cache !
      c.invalidate-post post.id, req.user.name
      # TODO broadcast post update

    res.json r
  destroy : (req, res, next) ->
    db = pg.procs
    if post-id = parse-int req.params.post
      # guard is post owner or super
      err, owns-post <- db.owns-post post-id, req.user?id
      if err then return next err
      return next 404 unless owns-post.length or !req?user?rights?super
      # we don't really destroy, we just archive
      err <- db.archive-post post-id
      if err then return next err
      res.json {success: true}
    else
      next 404
@products =
  show: (req, res, next) ->
    return next 404 unless id = req.params.product
    err, product <- db.products.select-one { id }
    if err then return next err
    if product
      res.json product
    else
      next 404
@conversations =
  create: (req, res, next) ->
    user = req.user
    if not user
      return res.json success: false # not allowed to chat without a user

    site-id = req.body?site_id
    users   = req.body?users
    if not site-id or not users
      return next new Error "not enough info to find-or-create conversation"
    user0 =
      id   : users.0.id
      name : users.0.name
    user1 =
      id   : users.1.id
      name : users.1.name
    err, c <~ db.conversation-find-or-create site-id, [user0, user1]
    if err then return next err
    res.json c

  show: (req, res, next) ->
    user = req.user
    if not user
      return res.json success: false # not allowed to chat without a user

    id    = req.params.conversation
    limit = req.query.limit or 30

    err, c <~ db.conversations.by-id id
    if err
      console.error \conversations-show, req.path, err
      res.json success: false
      return
    if c
      # TODO be sure to check participants too
      may-participate = any (-> it.user_id is user.id), c.participants
      unless may-participate
        console.log \c, c
        return res.json success: false, type: \non-particant
      err, messages <- db.messages.by-cid c.id, (req.query.last || null), limit
      if err
        console.error \conversations-show, req.path, err
        res.json success: false
        return
      c.messages = messages
      c.success = true
      res.json c
    else
      console.error \conversations-show, "nothing"
      res.json success: false
# used for ajax/pagination of lefthand nav (thread listing)
@threads =
  show: (req, res, next) ->
    return next 404 unless forum-id = req.params.thread
    site = res.vars.site
    page = parse-int(req.query.page) or 1
    offset = (page - 1) * cvars.t-step
    limit = cvars.t-step
    err, threads <- db.top-threads site.id, forum-id, \recent, limit, offset
    if err then return next err
    res.json threads

# vim:fdm=indent
