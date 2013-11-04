require! {
  async
  \./rights
}

@homepage = (req, res, next) ->
  res.locals {
    cvars.cache-url
  }
  next!

@super-sites = (req, res, next) ->
  return next 404
  next!

@super = @super-users = (req, res, next) ->
  err, can-list-site-users <- rights.can-list-site-users req.user, res.vars.site.id
  if err then return next err

  return next 404 unless can-list-site-users

  active-page = parse-int(req.query.page) or 1
  step   = 35
  offset = (active-page - 1) * step
  cols   = [\id, \email, \name, \photo, \site_admin, \sys_admin, \verified, \created, \site_id, \actions]
  site   = res.vars.site

  with-site = if site.id is not 1
    {
      site_id: site.id
    }
  else
    {}

  err, a <- async.auto {
    obj-rows: db.users.all {limit: step, offset} <<< with-site, _
    qty: db.users.all-count {} <<< with-site, _
  }
  if err then return next err

  for o in a.obj-rows
    o.actions = "<button data-edit-user=#{JSON.stringify(o)}>Edit User</button>"

  # pass page var thru
  res.locals {
    cvars.cache-url
    cols
    active-page
    step
    rows:
      [[o[c] for c in cols] for o in a.obj-rows]

    a.qty
  }
  next!
