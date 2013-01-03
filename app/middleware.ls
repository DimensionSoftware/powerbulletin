
@https = (req, res, next) ->
  protocol = req.headers['x-forwarded-proto'] or 'http'
  host     = cvars.host
  uri      = req.url
  url      = "https://#{host}#{uri}"
  if protocol is 'http' # force ssl
    res.redirect url, 301
    # XXX should this cb(end) or ?
  else
    next!
