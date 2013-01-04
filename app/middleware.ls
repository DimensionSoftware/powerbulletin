require! {
  \fs
}

@multi-domain = (req, res, next) ->
  for i in ['', 2, 3, 4, 5] # localize cache domains
    rhh  = req.headers.host
    tld  = rhh.substr(rhh.last-index-of '.')    # extract tld
    rest = rhh.substr(0, rhh.last-index-of '.') # everything else
    host = rest.substr(rest.last-index-of '.')  # prune all subdomains

    app.locals["cache#{i}_url"] = "//#{cvars.cache_prefix}#{i}#{host}#{tld}"
  next!

@ip-lookup = (req, res, next) ->
  res.locals.remote-ip = req.headers['x-real-client-ip']
    or req.headers['remote-addr']
    or req.headers['client-ip']
    or req.headers['x-forwarded-for']
    or 'localhost'
  next!

# add additional js & css to any route (through layout)
@add-js = (paths = []) ->
  (req, res, next) ->
    res.locals.js_urls = res.locals.js_urls || [] +++ paths
    next!
@add-css = (paths = []) ->
  (req, res, next) ->
    links = map (path) -> {media:'screen',url:path}, paths
    res.locals.css_urls = res.locals.css_urls || [] +++ links
    next!

@require-https = (req, res, next) ->
  protocol = req.headers['x-forwarded-proto'] or 'http'
  host     = cvars.host
  uri      = req.url
  url      = "https://#{host}#{uri}"
  if protocol is 'http' # force ssl
    res.redirect url, 301
    # XXX should this cb(end) or ?
  else
    next!

ip-hits  = {}
html_509 = fs.read-file-sync('public/509.html').to-string!
@rate-limit = (req, res, next) ->
  whitelist = []
  ip = res.locals.remote-ip
  # don't block whitelisted people!
  if any whitelist, (.exec ip) then return next!

  # in ms, how long until their 'naughty status' will be nice again
  ttl = 3 * 60 * 1000

  # how many hits allowed within ttl
  threshold = 200

  # algorithm:
  # 1. increment ip hit count
  # 2. tickle ttl on hit count key
  # 3. if hit count past fixed threshold, block
  # if offender stops bugging us for at least the TTL, the block record will dissappear

  now = new Date
  rec = ip-hits[ip] ||= {}

  # zero hits if ttl has elapsed
  if rec.timestamp and (now - rec.timestamp) > ttl
    rec.hits = 0

  rec.hits ||= 0
  rec.hits++
  rec.timestamp = now

  if rec.hits > threshold
    # XXX: i feel like this will flood logs, but leaving it for now
    console.warn "rate_limit #{ip} #{rec.hits} #{req.url}"
    res.send html_509 509
  else
    next!
