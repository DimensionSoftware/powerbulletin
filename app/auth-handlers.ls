require! {
  fs
  async
  jade
  querystring
  pg:   \./postgres
  auth: \./auth
  __: lodash
}

{is-editing, is-admin, is-auth} = require \./path-regexps

@login = (req, res, next) ->
  domain   = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    console.warn "domain", domain

    auth-response = (err, user, info) ->
      if err then return next(err)
      if not user then return res.json { success: false }
      req.login user, (err) ->
        if err then return next(err)
        res.json { success: true }

    passport.authenticate('local', auth-response)(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@register = (req, res, next) ~>
  site     = res.vars.site
  domain   = site.current_domain
  passport = auth.passport-for-domain[domain]

  # TODO more validation
  req.assert('username').not-empty!is-alphanumeric!  # .len(min, max) .regex(/pattern/)
  req.assert('password').not-empty!  # .len(min, max) .regex(/pattern/)
  req.assert('email').is-email!

  if errors = req.validation-errors!
    console.warn errors
    res.json {errors}
  else
    username = req.body.username
    password = req.body.password
    email    = req.body.email
    (err, u) <- register-local-user site, username, password, email
    if err then return res.json success:false, errors:[ msg:err ]
    auth.send-registration-email u, site, (err, r) ->
      console.warn 'registration email', err, r
    res.json success:true, errors:[]

@verify = (req, res, next) ->
  v    = req.param \v
  site = res.vars.site
  err, r <- db.verify-user site.id, v
  if err then return next err
  if r
    req.session?passport?user = "#{r.name}:#{site.id}"
    res.redirect if is-email r.name then \/#choose else \/#validate
  else
    res.redirect \/#invalid

@forgot = (req, res, next) ->
  db    = pg.procs
  site  = res.vars.site
  email = req.body.email

  if not email
    res.json success: false, errors: [ msg:'Blank email' ]
    return

  err, user <- db.usr { email, site_id: site.id }
  if err
    res.json success: false, errors: [ err ]
    return

  if user
    err, user-forgot <- auth.user-forgot-password user
    if err
      res.json success: false, errors: [ err ]
      return

    err <- auth.send-recovery-email user-forgot, site
    if err
      res.json success: false, errors: [ err ]
    else
      res.json success: true
  else
    res.json success: false, errors: [ msg:'User not found' ]

@forgot-user = (req, res, next) ->
  site = res.vars.site
  hash = req.body.forgot
  err, user <- db.usr forgot: hash, site_id: site.id
  if err
    return res.json success: false, errors: [ err ]
  if user
    res.json success: true
  else
    res.json success: false, errors: [ "User not found" ]

@reset-password = (req, res, next) ->
  site = res.vars.site
  hash = req.body.forgot
  password = req.body.password

  err, user <- db.usr forgot: hash, site_id: site.id
  if err
    console.warn \usr, err
    return res.json success: false, errors: [ err ]

  if user
    auths-local = user.auths.local
    auths-local.password = auth.hash password
    auths-json = JSON.stringify auths-local
    err <- db.auths.update criteria: { type: \local, user_id: user.id }, data: { profile: auths-json }
    if err
      console.warn \auths-update, err
      return res.json success: false, errors: [ err ]

    err <- db.alias-blank user
    if err
      console.warn \alias-blank, err
      return res.json success: false, errors: [ err ]

    res.json success: true
  else
    console.warn \usr, "User not found"
    res.json success: false, errors: [ "User not found" ]

# TODO - validate username
@choose-username = (req, res, next) ->
  user = req.user
  if not user then return res.json success:false
  # only change username if it's an email address
  name = req.user.name.to-string!
  if name.length and not is-email name
    res.json {success:false,msg:'Name already chosen!'}
  db = pg.procs
  usr =
    user_id : user.id
    site_id : user.site_id
    name    : req.body.username
  (err, r) <- db.change-alias usr
  if err then return res.json {success:false, msg:'Name in-use!'}
  console.warn "Changed name to #{req.body.username}"
  req.session?passport?user = "#{req.body.username}:#{user.site_id}"
  res.json success:true

@login-facebook = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('facebook')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@login-facebook-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('facebook', { success-redirect: '/auth/facebook/finish', failure-redirect: '/auth/facebook/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

auth-finisher = (req, res, next) ->
  user = req.user
  first-visit = user.created_human.match /just now/i
  if first-visit
    res.send """
    <script type="text/javascript">
      window.opener.$('\#auth input[name=username]').val('#{user.name}');
      window.opener.switchAndFocus('on-login', 'on-choose', '\#auth input[name=username]');
      window.close();
    </script>
    """
  else
    res.send """
    <script type="text/javascript">
      window.opener.$.fancybox.close();
      window.opener.afterLogin();
      window.close();
    </script>
    """

@login-facebook-finish = auth-finisher

@login-google = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  scope    = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'

  if passport
    passport.authenticate('google', {scope})(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@login-google-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('google', { success-redirect: '/auth/google/finish', failure-redirect: '/auth/google/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@login-google-finish = auth-finisher

@login-twitter = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('twitter')(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@login-twitter-return = (req, res, next) ->
  domain = res.vars.site.current_domain
  err, passport <- auth.passport-for-domain domain
  if err then return next(err)
  if passport
    passport.authenticate('twitter', { success-redirect: '/auth/twitter/finish', failure-redirect: '/auth/twitter/finish?fail=1' })(req, res, next)
  else
    console.warn "no passport for #{domain}"
    res.send \500, 500

@login-twitter-finish = auth-finisher

@logout = (req, res, next) ->
  if req.user # guard
    unless req.user.transient then req.logout!
    redirect-url = req.param(\redirect-url) or req.header(\Referer) or '/'
    res.redirect redirect-url.replace(is-editing, '').replace(is-admin, '').replace(is-auth, '')
  else
    res.redirect '/'

@user = (req, res, next) ->
  req.user ||= null
  if req.user
    res.json __.omit(req.user, \auths)
  else
    res.json null

@init-with-app = (app, mw) ->
  app.post '/auth/login',           mw, @login
  app.post '/auth/register',        mw, @register
  app.post '/auth/choose-username', mw, @choose-username
  app.get  '/auth/user',            mw, @user
  app.get  '/auth/verify/:v',       mw, @verify
  app.post '/auth/forgot',          mw, @forgot
  app.post '/auth/forgot-user'      mw, @forgot-user
  app.post '/auth/reset-password'   mw, @reset-password

  app.get  '/auth/facebook',        mw, @login-facebook
  app.get  '/auth/facebook/return', mw, @login-facebook-return
  app.get  '/auth/facebook/finish', mw, @login-facebook-finish

  app.get  '/auth/google',          mw, @login-google
  app.get  '/auth/google/return',   mw, @login-google-return
  app.get  '/auth/google/finish',   mw, @login-google-finish

  app.get  '/auth/twitter',         mw, @login-twitter
  app.get  '/auth/twitter/return',  mw, @login-twitter-return
  app.get  '/auth/twitter/finish',  mw, @login-twitter-finish

  app.get  '/auth/logout',          mw, @logout
