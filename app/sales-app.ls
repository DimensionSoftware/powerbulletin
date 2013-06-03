require! express
require! \../component/SalesLoader
require! jsu: \./js-urls

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/' (req, res, next) ->
  scripts =
    * jsu.jquery
    * jsu.jquery-ui
    * jsu.jquery-history
    * jsu.jquery-history-native
    * jsu.jquery-nicescroll
    * jsu.raf
    * jsu.powerbulletin-sales

  locals = {scripts} <<< cvars
  sl = new SalesLoader {locals}
  res.content-type \html
  res.send sl.html(false)

module.exports = s-app
