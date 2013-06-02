require! express

# would like to just call it app, but global 'app' is reserved
s-app = express!

s-app.get '/' (req, res, next) ->
  res.send 'Hello, Sales!'

module.exports = s-app
