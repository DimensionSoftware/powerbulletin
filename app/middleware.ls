require! {
  async
  fs
  geoip
  \./menu
  pg: \./postgres
}

# XXX vars is an alternative to locals that isn't used in templates (not sent to client)
@vars = (req, res, next) ->
  res.vars = {}
  next!

@cvars = (req, res, next) ->
  # copy over any wanted cvars into vars land
  res.locals.env = global.env

  # cacheUrls should always be available
  for k,v of cvars
    if k.match /^cache\d?Url$/ or k.match /authDomain/
      res.locals[k] = v

  next!

@multi-domain = (req, res, next) ->
  err, site <- db.site-by-domain req.hostname
  if err then return next err

  if site
    {id, name, current_domain, domain_id, domain_config, config} = site
    res.vars.site = site
    res.locals.site-id            = id
    res.locals.site-name          = name
    res.locals.current-domain     = current_domain
    res.locals.header             = config.header
    res.locals.analytics          = config.analytics
    res.locals.invite-only        = config.invite-only
    res.locals.social             = config.social
    res.locals.admin-chat         = config.admin-chat
    res.locals.fixed-header       = config.fixed-header
    res.locals.style              = config.style
    res.locals.newsletter-action  = config.newsletter-action or ''
    res.locals.newsletter-msg     = config.newsletter-msg or ''
    res.locals.logo               = config.logo
    res.locals.private            = config.private
    res.locals.private-background = config.private-background
    res.locals.meta-keywords      = config.meta-keywords or ''
    res.locals.domain-style       = domain_config.style
    res.locals.domain-id          = domain_id
    res.locals.cache-buster       = config.cache-buster or '' # default
    for i in ['', 2, 3, 4, 5]
      res.locals["cache#{i}Url"] = cvars["cache#{i}Url"]
    next!
  # if no site matches and there is a leading m or www, then try without
  else if m = req.hostname.match /^(www|m)\.(.+)$/i
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

# assumes multi-domain is already ran which populates res.locals.private
@private-site = (req, res, next) ->
  # we are gonna show a stripped down site with a login dialog unless one of these two guards fire
  return next! unless res.locals.private # only private sites run this middleware
  return next! if req.user # only run this middleware when req.user is null/undefined

  site    = res.vars.site
  site-id = site.id
  tasks =
    menu: db.menu site-id, _

  err, async-locals <- async.auto tasks
  if err then return next err

  res.locals async-locals

  res.locals {site-id}

  # set random background
  if m = site.config.menu
    bgs = menu.flatten m
      |> sort-by (-> Math.random!)
      |> filter  (-> it.form.background)
      |> map     (-> it.form.background.trim!)
    if bgs
      res.locals.backgrounds = bgs   # all
      res.locals.background  = bgs.0 # active

  res.mutant \privateSite # do _not_ call next because this is the end of the road

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
  lat = req.cookies?lat
  lng = req.cookies?lng
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

@require-admin = (req, res, next) -> # guard
  if not req?user?rights?super then next 404 else next!

ip-hits  = {}
html_509 = fs.read-file-sync('public/509.html').to-string!
@rate-limit = (req, res, next) ->
  # in dev mode don't rate limit!! for goodness sakes man ; )
  unless process.env.NODE_ENV in [\production \staging] then return next!

  whitelist = []
  ip = res.vars.remote-ip
  # don't block whitelisted people!
  if any (.exec ip), whitelist then return next!

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
