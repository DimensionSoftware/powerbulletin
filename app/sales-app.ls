require! express
require! \../component/SalesLoader
require! {
  csu: \./css-urls
  jsu: \./js-urls
}

# would like to just call it app, but global 'app' is reserved
s-app = express!

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

  stylesheets = [csu.jquery-fancybox]

  locals = {scripts, stylesheets} <<< cvars
  sl = new SalesLoader {locals}
  res.content-type \html
  res.send sl.html(false)

module.exports = s-app
