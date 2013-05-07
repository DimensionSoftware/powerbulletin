require! {
  \fs
  \geoip
  pg: \./postgres
}

# XXX vars is an alternative to locals that isn't used in templates (not sent to client)
@vars = (req, res, next) ->
  res.vars = {}
  next!

@cvars = (req, res, next) ->
  # copy over any wanted cvars into vars land
  res.locals.env = process.env.NODE_ENV or \development
  next!

@multi-domain = (req, res, next) ->
  err, site <- db.site-by-domain req.host
  if err then return next err

  if site
    {id, name, current_domain} = site
    res.vars.site = {id, name, current_domain}
    res.locals.site-id   = id
    res.locals.site-name = name
    for i in ['', 2, 3, 4, 5]
      res.locals["cache#{i}Url"] = cvars["cache#{i}Url"]
    next!
  # if no site matches and there is a leading m or www, then try without
  else if m = req.host.match /^(www|m)\.(.+)$/i
    shortened-host = m[2]
    err, redir-site <- db.site-by-domain shortened-host
    if err then return next err
    # if we find a site here, then we need to redirect
    if redir-site
      target = "#{req.protocol}://#{shortened-host}#{req.url}"
      console.warn {redirect:target}
      return res.redirect target
    else
      return next 404
  else
    next 404

@ip-lookup = (req, res, next) ->
  res.vars.remote-ip = req.headers['x-real-client-ip']
    or req.headers['remote-addr']
    or req.headers['client-ip']
    or req.headers['x-forwarded-for']
    or \127.0.0.1
  next!

@geo = (req, res, next) ->
  # try specific, passed-in client position for request
  lat = req.params.lat
  lng = req.params.lng
  if lng and lat # use!
    geo =
      longitude: lng
      latitude:  lat
    res.vars.geo = geo
    return next!

  # try cookie'd request
  lat = req.cookies.lat
  lng = req.cookies.lng
  if lng and lat # use!
    geo =
      longitude: lng
      latitude:  lat
    res.vars.geo = geo
    return next!

  # TODO use logged-in user's zipcode third

  # use maxmind if nothing else is available
  city = new geoip.City(cvars.maxmind)
  if not res.vars.remote-ip # set it from headers
    res.vars.remote-ip = req.headers['x-real-client-ip']
  res.vars.geo =
    city.lookup-sync res.vars.remote-ip

  # finally, default
  def = res.vars.geo or {}
  unless def?latitude  then def.latitude  = 0
  unless def?longitude then def.longitude = 0
  res.vars.geo = def
  next!

# add additional js & css to any route (through layout)
@add-js = (paths = [], add-changeset = true) ->
  if add-changeset
    # to blow cache at deploy time
    paths = ["#{p}?#{CHANGESET}" for p in paths]

  (req, res, next) ->
    res.locals.js-urls = res.locals.js-urls || [] ++ paths
    next!

@add-css = (paths = [], add-changeset = true) ->
  if add-changeset
    # to blow cache at deploy time
    paths = ["#{p}?#{CHANGESET}" for p in paths]

  (req, res, next) ->
    links = map (path) -> {media:'screen',url:path}, paths
    res.locals.css-urls = res.locals.css-urls || [] ++ links
    next!

ip-hits  = {}
html_509 = fs.read-file-sync('public/509.html').to-string!
@rate-limit = (req, res, next) ->
  # in dev mode don't rate limit!! for goodness sakes man ; )
  unless process.env.NODE_ENV in [\production \staging] then return next!

  whitelist = []
  ip = res.vars.remote-ip
  # don't block whitelisted people!
  if any whitelist, (.exec ip) then return next!

  # in ms, how long until their 'naughty status' will be nice again
  ttl = 3 * 60 * 1000

  # how many hits allowed within ttl
  threshold = 2500

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
    res.send html_509, 509
  else
    next!
