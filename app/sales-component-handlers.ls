require! {
  async
  \./rights
  \../shared/shared-helpers
}

@homepage = (req, res, next) ->
  res.locals.cache-url = cvars.cache-url
  next!

@super-sites = (req, res, next) ->
  return next 404
  next!

@super = @super-users = (req, res, next) ->
  err, can-list-site-users <- rights.can-list-site-users req.user, res.vars.site.id
  if err then return next err

  return next 404 unless can-list-site-users

  q = req.query.q # optional query filter
  active-page = parse-int(req.query.page) or 1
  site   = res.vars.site
  step   = site.config.items-per-page || 20
  offset = (active-page - 1) * step
  cols   = [\id, \name, \email, \photo, \site_admin, \sys_admin, \verified, \created]

  with-site = if site.id is not 1
    { site_id: site.id }
  else
    { }

  err, a <- async.auto {
    obj-rows: db.users.all {limit: step, offset, q} <<< with-site, _
    qty: db.users.all-count {q} <<< with-site, _
  }
  if err then return next err

  for o in a.obj-rows
    o = shared-helpers.add-dates o
    o.name = "<a href=\"\#\" data-edit-user=\'#{JSON.stringify(o)}\'>#{o.name}</span>"
    o.created = "<span title=\"@ #{o.created_iso}\">#{o.created_human}</span>"

  # pass page var thru
  [res.locals[k] = v for k,v of {
    cvars.cache-url
    cols
    active-page
    step
    rows:
      [[o[c] for c in cols] for o in a.obj-rows]

    a.qty
  }]
  next!
