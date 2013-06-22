require! express
require! \../component/SalesLoader
require! {
  csu: \./css-urls
  jsu: \./js-urls
  \./pb-handlers
  \./auth-handlers
}

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/dynamic/css/:file' pb-handlers.stylus

s-app.get '/' (req, res, next) ->
  scripts =
    * jsu.jquery
    * jsu.jquery-cookie
    * jsu.jquery-fancybox
    * jsu.jquery-history
    * jsu.jquery-history-native
    * jsu.jquery-nicescroll
    * jsu.jquery-ui
    * jsu.raf
    * jsu.powerbulletin-sales

  stylesheets =
    * csu.jquery-fancybox
    * csu.master-sales

  locals = {scripts, stylesheets} <<< cvars
  sl = new SalesLoader {locals}
  res.content-type \html
  res.send sl.html(false)

s-app.get '/ajax/check-domain-availability' (req, res, next) ->
  domain = req.query.domain
  err, domain-exists <- db.domain-by-name-exists domain
  if err then return next err
  res.json {available: !domain-exists}

s-app.post '/ajax/can-has-site-plz', express.body-parser(), (req, res, next) ->
  site = req.body
  console.log {site}
  err, result <- db.create-site site
  if err then return next err
  console.log result
  res.json result

auth-handlers.init-with-app s-app, [express.body-parser!]

module.exports = s-app
