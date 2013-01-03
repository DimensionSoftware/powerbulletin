require! {
  \fs
}
global <<< require \prelude-ls


@ip-lookup = (req, res, next) ->
  res.locals.remote-ip = req.headers['x-real-client-ip']
    or req.headers['remote-addr']
    or req.headers['client-ip']
    or req.headers['x-forwarded-for']
    or 'localhost'
  next!

# add additional js & css to any route (through jade layouts)
@add-js = (paths = []) ->
  (req, res, next) ->
    res.locals.js-urls = res.local(\js-urls).concat(paths)
    next!
@add-css = (paths = []) ->
  (req, res, next) ->
    links = paths.map (path) -> # build links
      {media:'screen', url:path}
    res.locals.css-urls = res.local(\css-urls).concat(links)
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
      if any(whitelist, (r) -> r.exec(ip)) then return next!

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

