require! express
require! \../component/SalesLoader

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/' (req, res, next) ->
  locals = {} <<< cvars
  sl = new SalesLoader {locals}
  res.content-type \html
  res.send sl.html(false)

module.exports = s-app
