
@homepage = (req, res, next) ->
  res.locals {
    cvars.cache-url
  }
  next!

@super = @superSites = @superUsers = (req, res, next) ->
  # pass page var thru
  res.locals {
    cvars.cache-url
    cols: [\foo, \bar]
    rows: [[1, 2], [3, 4]]
    qty: 100
    active-page: parse-int(req.query.page) or 1
  }
  next!
