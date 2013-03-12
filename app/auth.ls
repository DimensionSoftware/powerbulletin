# ISSUES
# - every site needs its own credentials for 3rd party auth

require! {
  \async
  \passport
  \passport-local
  \passport-facebook
  \passport-twitter
  \passport-google

  pg: './postgres'
  passport.Passport
}

export passport-for-site = {}

# XXX - only exported for debugging convenience
# XXX - what's a good way to hash local passwords?
export hash = (s) -> s

# site-aware passport middleware wrappers
export mw =
  initialize: (req, res, next) ~>
    domain   = res.locals.site?.domain
    if passport = @passport-for-site[domain]
      passport.mw-initialize(req, res, next)
    else
      next(404)
  session: (req, res, next) ~>
    domain   = res.locals.site?.domain
    if passport = @passport-for-site[domain]
      passport.mw-session(req, res, next)
    else
      next(404)

# XXX - only exported for debugging convenience
export valid-password = (user, password) ->
  return false if not user or not password
  hash(user?.auths?.local?.password) == hash(password)

# XXX - gotdamn
pg.init ~>
  db = pg.procs
  (err, domains) <~ db.domains
  if err then return throw err

  create-passport = (domain, cb) ->
    (err, site) <~ db.site-by-domain domain
    if err then return throw err

    passport-for-site[domain] = pass = new Passport

    # middleware functions for this passport
    pass.mw-initialize = pass.initialize()
    pass.mw-session    = pass.session()

    pass.serialize-user (user, done) ~>
      parts = "#{user.name}:#{user.site_id}"
      console.warn "serialize", parts
      done null, parts

    pass.deserialize-user (parts, done) ~>
      [name, site_id] = parts.split ':'
      console.warn "deserialize", name, site_id
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
      clientID      : site.config?.facebook-client-id     or \x
      client-secret : site.config?.facebook-client-secret or \x
      callbackURL   : "http://#{domain}/auth/facebook/return"
    pass.use new passport-facebook.Strategy facebook-options, (access-token, refresh-token, profile, done) ->
      console.warn 'facebook profile', profile
      err, name <- db.unique-name profile.display-name
      u =
        type    : \facebook
        id      : profile.id
        profile : profile._json
        site_id : site.id
        name    : name
      (err, user) <- db.find-or-create-user u
      console.warn 'err', err if err
      done(err, user)

    twitter-options =
      consumer-key    : site.config?.twitter-consumer-key    or \x
      consumer-secret : site.config?.twitter-consumer-secret or \x
      callbackURL     : "http://#{domain}/auth/twitter/return"
    pass.use new passport-twitter.Strategy twitter-options, (access-token, refresh-token, profile, done) ->
      console.warn 'twitter profile', profile
      err, name <- db.unique-name profile.display-name
      u =
        type    : \twitter
        id      : profile.id
        profile : profile._json
        site_id : site.id
        name    : name
      (err, user) <- db.find-or-create-user u
      console.warn 'err', err if err
      done(err, user)

    google-options =
      returnURL : "http://#{domain}/auth/google/return"
      realm     : "http://#{domain}/"
    pass.use new passport-google.Strategy google-options, (identifier, profile, done) ->
      console.warn 'google id', identifier
      console.warn 'google profile', profile
      err, name <- db.unique-name profile.display-name
      if err then cb err;return
      u =
        type    : \google
        id      : profile.id
        profile : profile._json
        site_id : site.id
        name    : name
      (err, user) <- db.find-or-create-user u
      console.warn 'err', err if err
      done(err, user)

    cb(null, pass)

  (err) <- async.forEach domains, create-passport
  if err then return cb(err)
  #console.warn 'passport-for-site', keys passport-for-site

# vim:fdm=indent
