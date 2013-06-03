require! express
require! \../component/SalesLoader
require! {
  csu: \./css-urls
  jsu: \./js-urls
  \./pb-handlers
}

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/dynamic/css/:file' pb-handlers.stylus

s-app.get '/' (req, res, next) ->
  scripts =
    * jsu.jquery
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

module.exports = s-app
