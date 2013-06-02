require! express
require! \../component/SalesLayout

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/' (req, res, next) ->
  locals = {} <<< cvars
  sl = new SalesLayout {locals}
  res.content-type \html
  res.send sl.html!

module.exports = s-app
