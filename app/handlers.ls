
@hello = (req, res) ->
  res.send "hello #{res.locals.remote-ip}"
