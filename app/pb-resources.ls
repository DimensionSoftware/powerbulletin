require! {
  pg: \./postgres
  c: \./cache
  h: \./helpers
  sioa: \socket.io-announce
  \fs
  \stylus
  \mkdirp
}

announce = sioa.create-client!

save-stylus = (domain, stylus) ->
  base = "public/domains/#domain"
  err <- mkdirp base
  if err then console.error \mkdirp.rename, err; return # guard
  err <- fs.write-file "#base/site.css" stylus
  if err then console.error \fs.write-file, err; return # "
  true

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
      # extract specific keys
      site.config <<< { [k, v] for k, v of req.body when k in [\postsPerPage \metaKeywords] }
      err, r <- db.site-update site
      if err then return next err
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

      # generate domain-specific css
      const suffix = \Secret
      domain.config.stylus = auths
        |> filter (-> it.index-of(suffix) isnt -1 and req.body[it])                # only auths with values
        |> map (-> ".has-#{take-while (-> it in [\a to \z]), it}{display:inline}") # make css selectors
        |> join ''
      if domain.config.stylus.length then domain.config.stylus += '.has-auth{display:block}'
      err, r <- db.domain-update domain # save!
      if err then return next err
      save-stylus domain.name, domain.config.stylus
      res.json success:true
@users =
  create : (req, res) ->
    if not req?user?rights?super then return next 404 # guard
    user = req.params.user
    # munge data
    (err, user) <- db.find-or-create user
    res.json user
@posts =
  index   : (req, res) ->
    res.locals.fid = req.query.fid
    res.locals.pid = req.query.pid
    res.render \post-new
  new     : null
  create  : (req, res, next) ->
    return next(404) unless req.user
    db           = pg.procs
    post         = req.body
    post.user_id = req.user.id
    post.html    = h.html post.body
    post.ip      = res.vars.remote-ip
    post.tags    = h.hash-tags post.body
    err, ap-res <- db.add-post post
    if err then return next err

    if ap-res.success # if success then blow cache
      post.id = ap-res.id
      c.invalidate-post post.id # blow cache!

    unless post.parent_id
      err, new-post <- db.post post.id
      announce.emit \thread-create new-post
    else
      err, new-post <- db.post post.id
      new-post.posts = []
      announce.emit \post-create new-post

    res.json ap-res
  show    : (req, res, next) ->
    db = pg.procs
    if post-id = parse-int(req.params.post)
      err, post <- db.post post-id
      if err then return next err
      res.json post
    else
      return next 404
  edit    : (roq, res, next) ->
    # owns post
  update  : (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    # is_owner req?user
    err, owns-post <- db.owns-post req.body.id, req.user?id
    if err then return next err
    return next 404 unless owns-post.length
    # TODO secure & csrf
    # save post
    req.body.user_id = req.user.id
    req.body.html = h.html req.body.body
    post = req.body
    err, r <- db.edit-post(req.user, post)
    if err then return next err

    if r.success
      # blow cache !
      c.invalidate-post post.id

    res.json r
  destroy : (req, res, next) ->
    if not req?user?rights?super then return next 404 # guard
    # TODO currently only super users can censor.  how about post owners?
    db = pg.procs

    if post-id = parse-int(req.params.post)
      # we don't really destroy, we just archive
      err <- db.archive-post(post-id)
      if err then return next err
      res.json {success: true}
    else
      next 404

# vim:fdm=indent
