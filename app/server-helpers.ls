# XXX server-side helpers merged into global
require! {
  fs
  stylus
  fluidity
  crypto
  bbcode
  nodemailer
  strftime
  h: \../shared/shared-helpers
  auth:  \./auth
  cvars: \./load-cvars
}
sanitize = require('express-validator/node_modules/validator').sanitize

@cache-buster = ->
  crypto.create-hash \sha1 .update(Math.floor((new Date).get-time! * Math.random!).to-string!).digest \hex

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
  unless body?length then return '' # guard
  body.match(/#\w+/g)?map (tag) -> tag?replace(/^#/, '').toLowerCase!

@hash-tags-replace = (body, fn) ->
  unless body?length then return '' # guard
  body?replace /#\w+/g, fn

# find all @attags in a string
@at-tags = (body) ->
  unless body?length then return '' # guard
  body.match(/@\w+/g)?map (tag) -> tag?replace(/^@/, '')

@at-tags-replace = (body, fn) ->
  unless body?length then return '' # guard
  body.replace /@\w+/g, fn

# take marked up text and turn it into html
@html = (body) ~>
  unless body?length then return # guard
  # TODO - escape html before sending to bbcode parser
  b0 = @hash-tags-replace body, (hash-tag) ->
    """<a class="mutant hash-tag" href="/search?q=#{encode-URI-component hash-tag.to-lower-case!}">#hash-tag</a>"""
  b1 = @at-tags-replace b0, (at-tag) ->
    """<a class="mutant at-tag" href="/user/#{encode-URI-component at-tag.replace(/^@/, '')}">#at-tag</a>"""
  bbcode.parse b1

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
    if err                then return cb err
    if r.success is false then return cb r

    u.id = r.id

    default-site-ids = global.cvars.default-site-ids |> filter (-> it is not site.id)
    err <~ db.aliases.add-to-user r.id, default-site-ids, { name: username, +verified }
    if err then return cb err

    #@login(req, res, cb) # on successful registration, automagically @login, too
    cb null, u

@format =
  chat-message: (s, options={}) ->
    t0 = @replace-urls(s, @embedded)
    t1 = sanitize(t0).xss!
  url-pattern: /(\w+:\/\/[\w\.\?\&=\%\/-]+[\w\?\&=\%\/-])/g
  replace-urls: (s, fn) ->
    s.replace @url-pattern, fn
  embedded: (url) ->
    if url.match /\.(jpe?g|png|gif)$/i
      """<img src="#{url}" />"""
    else
      """<a href="#{url}" target="_blank">#{url}</a>"""


@render-css = (file-name, cb) ->
  if file-name in global.cvars.acceptable-stylus-files
    fs.read-file "app/stylus/#{file-name}", (err, buffer) ->
      if err then return cb err
      cvars = global.cvars
      options =
        compress: true
      stylus(buffer.to-string!, options) # build css
        .define \cache-url  cvars.cache-url
        .define \cache2-url cvars.cache2-url
        .define \cache3-url cvars.cache3-url
        .define \cache4-url cvars.cache4-url
        .define \cache5-url cvars.cache5-url
        .set \paths [\app/stylus]
        .use fluidity!
        .render cb
  else
    cb "#file-name is not allowed"

@move = (src, dst, cb) ->
  _is = fs.create-read-stream src
  _os = fs.create-write-stream dst
  _is.on \end, (err) ->
    err2 <- fs.unlink src
    cb(err)
  _is.pipe(_os)

# vim:fdm=marker
