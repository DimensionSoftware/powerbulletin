
@homepage = (req, res, next) ->
  next!

@super = @superSites = @superUsers = (req, res, next) ->
  # pass page var thru
  res.locals.active-page req.query.page  if req.query.page
  next!
