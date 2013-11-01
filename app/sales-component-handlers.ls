require! async

@homepage = (req, res, next) ->
  res.locals {
    cvars.cache-url
  }
  next!

@super-sites = (req, res, next) ->
  return next 404
  next!

@super = @super-users = (req, res, next) ->
  return next(404) unless req.user?rights.super

  active-page = parse-int(req.query.page) or 1
  step   = 35
  offset = (active-page - 1) * step
  cols   = [\id, \email, \name, \photo, \site_admin, \sys_admin, \verified, \created, \site_id, \actions]

  err, a <- async.auto {
    obj-rows: db.users.all {limit: step, offset}, _
    qty: db.users.all-count {}, _
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
