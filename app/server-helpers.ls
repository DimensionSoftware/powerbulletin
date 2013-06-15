# XXX server-side helpers merged into global
require! {
  crypto
  bbcode
  nodemailer
  auth: \./auth
}

@caching-strategies =
  nocache: (res) ->
    # upstream caches and clients should not cache
    res.header 'Cache-Control', 'no-cache'
    res.header 'Pragma', 'no-cache'
  etag: (res, etag, client-ttl) ->
    return @nocache(res) if DISABLE_HTTP_CACHE
    res.header 'Cache-Control', "max-age=#{client-ttl}; must-revalidate"
    res.header 'ETag', etag
  lastmod: (res, last-modified, client-ttl) ->
    return @nocache(res) if DISABLE_HTTP_CACHE
    res.header 'Cache-Control', "max-age=#{client-ttl}; must-revalidate"
    res.header 'Last-Modified', last-modified.toUTCString()
  justage: (res, client-ttl) ->
    return @nocache(res) if DISABLE_HTTP_CACHE
    res.header 'Cache-Control', "max-age=#{client-ttl}; must-revalidate"

# meant to be used for etags
@sha1 = (str) ->
  str = crypto.create-hash('sha1').update(str).digest('hex')
  # supposedly the quotes are the proper way to format this, trying to follow rfcs
  '"' + str + '"'

# cache data in process memory
process-cached-data = {}
@process-cache = (key, time-ms, f) ->
  cache = process-cached-data
  cache[key] || cache[key] = {}
  (cb) ->
    now = new Date
    if (not cache[key].data and not cache[key].expiration-date) or (now > cache[key].expiration-date)
      f (err, data) ->
        if err
          return cb err, null
        else
          cache[key].data = data
          # javascript quirk: '-' means date arithmetic, '+' means string concatenation
          cache[key].expiration-date = new Date(now - -(time-ms))
          cb err, data
    else
      cb null, cache[key].data

@forum-path-parts = (path) ->
  parts = path?split /\//
  return unless parts # guard
  parts?shift!
  m     = last parts .match /-([\d]+)$/
  id    = m?[1]
  if id
    parts.pop!
    [parts, id]
  else
    [parts]

# find all #hashtags in a string
@hash-tags = (body) ->
  unless body?length then return # guard
  body.match(/#\w+/g)?map (tag) -> tag.replace(/^#/, '').toLowerCase!

# find all @attags in a string
@at-tags = (body) ->
  unless body?length then return # guard
  body.match(/@\w+/g)?map (tag) -> tag.replace(/^@/, '')

# take marked up text and turn it into html
@html = (body) ->
  unless body?length then return # guard
  # TODO - escape html before sending to bbcode parser
  # TODO - add #hashtag and @attag support
  bbcode.parse body

@expand-handlebars = (tmpl, vars) ->
  tmpl.replace /{{([\w-]+)}}/g, (m, p) ->
    vars?[p] || ""

@send-mail = (email, cb) ->
  smtp = nodemailer.create-transport \SMTP
  smtp.send-mail email, cb

@register-local-user = (site, username, password, email, cb=(->)) ->
  err, user <~ db.name-exists {email:email, site_id:site.id}
  if err
    cb 'Account in-use'
  else if user
    cb user # error w/ data
  else
    err, vstring <~ auth.unique-hash \verify, site.id
    if err then return cb err
    u =
      type    : \local
      profile : { password: auth.hash(password) }
      site_id : site.id
      name    : username
      email   : email
      verify  : vstring
    err, r <~ db.register-local-user u # couldn't use find-or-create-user because we don't know the id beforehand for local registrations
    if err then return cb err
    #@login(req, res, cb) # on successful registration, automagically @login, too
    cb null, u

# vim:fdm=marker
