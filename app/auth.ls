# ISSUES
# - every site needs its own credentials for 3rd party auth

require! {
  \passport
  \passport-local
  \passport-facebook
  \passport-twitter
  \passport-google

  pg: './postgres'
}
db = pg.procs

# XXX - only exported for debugging convenience
# XXX - what's a good way to hash local passwords?
@hash = (s) -> s

# XXX - only exported for debugging convenience
@valid-password = (user, password) ->
  return false if not user or not password
  @hash(user?.auth?.local?.password) == @hash(password)

# Local # {{{1
passport.use new passport-local.Strategy (username, password, done) ~>
  (err, user) <~ db.usr { name: username, site_id: 1 }  # XXX - how do i get site_id?
  if err then return done(err)
  if not user
    return done(null, false, { message: 'User not found' })
  if not valid-password(user, password)
    return done(null, false, { message: 'Incorrect password' })
  done(null, user)

# Facebook # {{{1
facebook-options =
  clientID      : \xxx
  client-secret : \xxx
  callbackURL   : 'http://www.pb.com/auth/facebook/return' # XXX - should not hardcodd site
passport.use new passport-facebook.Strategy facebook-options, (access-token, refresh-token, profile, done) ->
  (err, user) <- db.find-or-create-user {}
  done(err, user)

# Twitter # {{{1
twitter-options =
  consumer-key    : \xxx
  consumer-secret : \xxx
  callbackURL     : 'http://www.pb.com/auth/twitter/return' # XXX - should not hardcode site
passport.use new passport-twitter.Strategy twitter-options, (access-token, refresh-token, profile, done) ->
  (err, user) <- db.find-or-create-user {}
  done(err, user)

# Google # {{{1
google-options =
  returnURL : 'http://www.pb.com/auth/google/return'  # XXX - should not hardcode site
  realm     : 'http://www.pb.com/'
passport.use new passport-google.Strategy google-options, (identifier, profile, done) ->
  (err, user) <- db.find-or-create-user {}
  done(err, user)

# }}}

@passport = passport

# vim:fdm=marker
