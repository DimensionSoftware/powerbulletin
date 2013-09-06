require! {
  pg: \./postgres
  v: \./varnish
  c: \./cache
  h: \./server-helpers
  sioa: \socket.io-announce
  auth: \./auth
  menu: \./menu
  async
  fs
  mkdirp
  stylus
}

const base-css = \public/sites

announce = sioa.create-client!

ban-all-domains = (site-id) ->
  # varnish ban site's domains
  err, domains <- db.domains-by-site-id site-id
  if err then return next err
  for d in domains then v.ban-domain d.name

@sites =
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
      for f in [\style \postsPerPage \inviteOnly \private \analytics]
        if site.config[f] isnt req.body[f] then should-ban = true

      # save css to disk for site
      if site.config.style isnt req.body.style # only on change
        site.config.cache-buster = h.cache-buster!
        err <- mkdirp base-css
        if err then return next err
        (err, css) <- stylus.render site.config.style, {compress:true}
        if err then return res.json {success:false, msg:'CSS must be valid!'}
        err <- fs.write-file "#base-css/#{site.id}.css" css
        if err then return next err

      # update site
      site.name = req.body.name
      site.config <<< { [k, val] for k, val of req.body when k in # guard
        <[ postsPerPage metaKeywords inviteOnly private analytics style ]> }
      for c in <[ inviteOnly  private ]> # uncheck checkboxes?
        delete site.config[c] unless req.body[c]
      for s in <[ private analytics ]> # subscription tampering
        delete site.config[s] unless s in site.subscriptions
      err, r <- db.site-update site # save!
      if err then return next err

      # varnish ban
      ban-all-domains site.id if should-ban
      res.json success:true

    | \menu =>
      # save site config
      m = site.config?menu or []

      if id = req.body.id # active form
        form = { [k, v] for k,v of req.body when k in
          <[ id title dialog forumSlug locked comments pageSlug content url contentOnly separateTab ]> }
        menu-item = { id, form.title, form }
        m-path = menu.path-for-upsert(m, id.to-string!)
        site.config.menu = menu.struct-upsert m, m-path, menu-item

      # XXX - the upsert can only insert unless database id is propagated here
      console.warn \form, form
      console.warn \menu-item, menu-item
      console.warn \extracted, menu.extract menu-item
      err, r <- menu.db-upsert site, menu-item
      if err then return res.json success: false, hint: \menu.upsert, err: err
      if r.length
        menu-item.form.id = r.0.id
        m2 = site.config.menu
        site.config.menu = menu.struct-upsert m2, m-path, menu-item

      err, r <- db.site-update site
      if err then return res.json success: false, hint: \db.site-update

      ban-all-domains site.id # varnish ban
      res.json success:true

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

      ban-all-domains site.id # varnish ban
      res.json success:true

    | \domains =>
      # find domain
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

      # save css to disk
      err <- mkdirp base-css
      if err then return next err
      err <- fs.write-file "#base-css/#{domain.name}.css" domain.config.style

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
    post.forum_id = post.forum_id

    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      post.id = ap-res.id
      c.invalidate-post post.id, req.user.name # blow cache!

    unless post.parent_id
      err, new-post <- db.post site.id, post.id
      if err then return next err
      announce.emit \thread-create new-post
    else
      err, new-post <- db.post site.id, post.id
      if err then return next err
      new-post.posts = []
      announce.emit \post-create new-post

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
    if not req?user?rights?super then return next 404 # guard
    # is_owner req?user
    err, owns-post <- db.owns-post req.body.id, req.user?id
    if err then return next err
    return next 404 unless owns-post?length
    # TODO secure & csrf
    # save post
    req.body.user_id = req.user.id
    req.body.html = h.html req.body.body
    post = req.body
    err, r <- db.edit-post(req.user, post)
    if err then return next err

    if r.success
      # blow cache !
      c.invalidate-post post.id, req.user.name

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
    err, product <- db.products.find-one {
      criteria: {id}
      columns: [\id \description \price \config]
    }
    if err then return next err
    if product
      product.config = JSON.parse product.config # p00f--json'ify
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
    limit = 30

    err, c <~ db.conversation-by-id id
    if err
      console.error \conversations-show, req.path, err
      res.json success: false
      return
    if c
      # TODO be sure to check participants too
      may-participate = c?particpants?some (-> it.id is user.id)
      unless may-participate
        return res.json success: false, type: \non-particant
      err, messages <- db.messages-by-cid c.id, (req.query.last || null), limit
      if err
        console.error \conversations-show, req.path, err
        res.json success: false
        return
      c.messages = messages |> map (-> it.body = format.chat-message it.body; it)
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
