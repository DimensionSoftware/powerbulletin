# ISSUES
# - every site needs its own credentials for 3rd party auth

require! {
  \async
  \bcrypt
  \crypto
  \nodemailer
  \passport
  \passport-local
  \passport-facebook
  \passport-twitter
  \passport-google-oauth

  pg: './postgres'
  passport.Passport
}


# site-aware passport middleware wrappers
export mw =
  initialize: (req, res, next) ~>
    domain = res.vars.site?current_domain
    err, passport <~ @passport-for-domain domain
    if err then return next(err)
    if passport
      passport.mw-initialize(req, res, next)
    else
      next(404)
  session: (req, res, next) ~>
    domain = res.vars.site?current_domain
    err, passport <~ @passport-for-domain domain
    if err then return next(err)
    if passport
      passport.mw-session(req, res, next)
    else
      next(404)

#
export hash = (s) ->
  bcrypt.hash-sync s, 5

#
export valid-password = (user, password) ->
  return false if not user or not password
  bcrypt.compare-sync password, user?auths?local?password

export verify-string = ->
  buffer = crypto.random-bytes(32)
  char = (c) ->
    c2 = Math.floor(c / 10.24) # fp-math? really??
    c3 = c2 + 97
    String.from-char-code c3
  [ char v for v,i in buffer ].join ''

export unique-verify-string-for-site = (site-id, cb) ->
  # if all these fail, you've won the lottery
  # one should pass,
  # usually the first
  candidates = [ verify-string! for i from 1 to 10 ] # it's too bad this couldn't be an infinite lazy list

  unique = (v, cb) ->
    (err, found-alias) <- pg.procs.alias-by-verify site-id, v
    if err then return cb err
    if found-alias
      cb false
    else
      cb true

  async.detect candidates, unique, (uv) ->
    cb null, uv

export email-template-text = """
Welcome to {{site-name}}, {{user-name}}.

To verify your account, please visit:

  https://{{site-domain}}/auth/verify/{{user-verify}}

"""

export email-template-html = """
"""

#
export expand-handlebars = (tmpl, vars) ->
  tmpl.replace /{{([\w-]+)}}/g, (m, p) ->
    vars?[p] || ""

#
export send-registration-email = (user, site, cb) ->
  smtp = nodemailer.create-transport 'SMTP'
  vars =
    # I have to quote the keys so that the template-vars with dashes will get replaced.
    "site-name"   : site.name
    "site-domain" : site.current_domain
    "user-name"   : user.name
    "user-verify" : user.verify
  email =
    from    : "noreply@powerbulletin.com"
    to      : user.email
    subject : "Welcome to #{site.name}"
    text    : expand-handlebars email-template-text, vars
  smtp.send-mail email, cb

export create-passport = (domain, cb) ->
  (err, site) <~ db.site-by-domain domain
  if err then return cb(err)

  current-domain = find (-> it.name == site.current_domain), site.domains
  if not current-domain then return cb(new Error("domain object for #{site.current_domain} could not be found"))
  config = current-domain.config

  pass = new Passport

  # middleware functions for this passport
  pass.mw-initialize = pass.initialize()
  pass.mw-session    = pass.session()

  pass.serialize-user (user, done) ~>
    parts = "#{user.name}:#{user.site_id}"
    #console.warn "serialize", parts
    done null, parts

  pass.deserialize-user (parts, done) ~>
    [name, site_id] = parts.split ':'
    #console.warn "deserialize", name, site_id
    (err, user) <~ db.usr {name, site_id}
    done err, user

  pass.use new passport-local.Strategy (username, password, done) ~>
    (err, user) <~ db.usr { name: username, site_id: site.id }  # XXX - how do i get site_id?
    if err then return done(err)
    if not user
      console.warn 'no user'
      return done(null, false, { message: 'User not found' })
    if not valid-password(user, password)
      console.warn 'invalid password', password, user
      return done(null, false, { message: 'Incorrect password' })
    console.warn 'ok'
    done(null, user)

  facebook-options =
    client-ID     : config?facebook-client-id     or \x
    client-secret : config?facebook-client-secret or \x
    callback-URL  : "http://#{domain}/auth/facebook/return"
  pass.use new passport-facebook.Strategy facebook-options, (access-token, refresh-token, profile, done) ->
    console.warn 'facebook profile', profile
    err, name <- db.unique-name name: profile.display-name, site_id: site.id
    if err then return cb err
    err, vstring <- unique-verify-string-for-site site.id
    if err then return cb err
    u =
      type    : \facebook
      id      : profile.id
      profile : profile._json
      site_id : site.id
      name    : name
      verify  : vstring
    (err, user) <- db.find-or-create-user u
    console.warn 'err', err if err
    done(err, user)

  twitter-options =
    consumer-key    : config?twitter-consumer-key    or \x
    consumer-secret : config?twitter-consumer-secret or \x
    callback-URL    : "http://#{domain}/auth/twitter/return"
  pass.use new passport-twitter.Strategy twitter-options, (access-token, refresh-token, profile, done) ->
    console.warn 'twitter profile', profile
    err, name <- db.unique-name name: profile.display-name, site_id: site.id
    if err then return cb err
    err, vstring <- unique-verify-string-for-site site.id
    if err then return cb err
    u =
      type    : \twitter
      id      : profile.id
      profile : profile._json
      site_id : site.id
      name    : name
      verify  : vstring
    (err, user) <- db.find-or-create-user u
    console.warn 'err', err if err
    done(err, user)

  google-options =
    client-ID     : config?google-consumer-key    or \x
    client-secret : config?google-consumer-secret or \x
    callback-URL  : "https://#{domain}/auth/google/return"
  pass.use new passport-google-oauth.OAuth2Strategy google-options, (access-token, refresh-token, profile, done) ->
    console.warn 'google profile', profile
    err, name <- db.unique-name name: profile.display-name, site_id: site.id
    if err then return cb err
    err, vstring <- unique-verify-string-for-site site.id
    if err then return cb err
    # TODO - store profile.picture if available
    u =
      type    : \google
      id      : profile.id
      profile : profile._json
      site_id : site.id
      name    : name
      verify  : vstring
    console.warn \u, u
    (err, user) <- db.find-or-create-user u
    console.warn 'err', err if err
    done(err, user)

  cb(null, pass)

export passports = {}

export passport-for-domain = (domain, cb) ~>
  if @passports[domain]
    #console.log "found cached passport for #domain"
    cb null, @passports[domain]
  else
    err, pass <~ @create-passport domain
    if err then return cb err
    if pass
      #console.log "created new passport for #domain"
      @passports[domain] = pass
      cb null, pass
    else
      #console.log "could not create passport for #domain"
      cb new Error("Could not create Passport for #domain.")

# vim:fdm=indent
