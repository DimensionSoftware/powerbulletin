# XXX server-side helpers merged into global
require! {
  fs
  stylus
  fluidity
  crypto
  bbcode
  nodemailer
  strftime
  v: \./varnish
  h: \../shared/shared-helpers
  auth:  \./auth
  cvars: \./load-cvars
}
sanitize = require('express-validator/node_modules/validator').sanitize

@ban-all-domains = (site-id) ->
  # varnish ban site's domains
  err, domains <- db.domains-by-site-id site-id
  if err then return next err
  for d in domains then v.ban-domain d.name

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

@render-css-fn = ({define=[],use=[],set=[]}) ->
  (file-name, cb) ->
    if file-name in global.cvars.acceptable-stylus-files
      fs.read-file "app/stylus/#{file-name}", (err, buffer) ->
        if err then return cb err
        cvars = global.cvars
        options =
          compress: true
        s = stylus(buffer.to-string!, options) # build css
        for args in define
          s.define.apply s, args
        for args in set
          s.set.apply s, args
        for args in use
          s.use.apply s, args
        s.define \cache-url  cvars.cache4-url # consolidate & mv assets to lesser-used-domain (browser speed)
          .set \paths [\app/stylus]
          .use fluidity!
          .render cb
    else
      cb "#file-name is not allowed"
@render-css-to-file = (site-id, file-name, cb) ~>
  fn = @render-css-fn define:[[\site-id, site-id]]
  fn file-name, (err, blocks) ->
    if err then return cb err
    css-file = "public/sites/#site-id/#file-name".replace /\.styl$/, \.css
    (err) <- fs.write-file css-file, blocks
    if err then cb err
    cb null
@render-css = (file-name, cb) ->
  fn = @render-css-fn define:[[]]
  fn file-name, cb

@move = (src, dst, cb) ->
  _is = fs.create-read-stream src
  _os = fs.create-write-stream dst
  _is.on \end, (err) ->
    err2 <- fs.unlink src
    cb(err)
  _is.pipe(_os)

@rpad = (n, str) ->
  if str.length >= n
    str
  else
    str + Str.repeat(n - str.length, ' ')

@lpad = (n, str) ->
  if str.length >= n
    str
  else
    Str.repeat(n - str.length, ' ') + str

@dev-log-format = (tokens, req, res) ->
  status = res.status-code
  len    = parse-int res.get-header(\Content-Length), 10
  color  = switch
  | status >= 500 => 31
  | status >= 400 => 31
  | status >= 300 => 36
  | otherwise     => 32

  len = if is-NaN len then '' else len
  "\x1b[38;5;222m#{@lpad 7, req.method} \x1b[90m(\x1b[#{color}m#{res.status-code}\x1b[90m) \x1b[38;5;255m#{req.host}#{req.originalUrl} \x1b[38;5;197m#{new Date - req._start-time}ms - #{len}\x1b[0m"

@prod-log-format = (tokens, req, res) ->
  status = res.status-code
  len    = parse-int res.get-header(\Content-Length), 10
  len    = if is-NaN len then '' else len
  "#{@lpad 7, req.method} (#{res.status-code}) #{req.host}#{req.originalUrl} #{new Date - req._start-time}ms - #{len} - #{req.ip}"

# vim:fdm=marker
