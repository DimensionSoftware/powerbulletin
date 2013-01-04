require! {
  stylus
  fluidity
  async
  fs
}

@homepage = (req, res) ->
  res.render 'layout'

@hello = (req, res) ->
  res.send "hello #{res.locals.remote-ip}"


cvars.acceptable-stylus-files = fs.readdir-sync 'app/stylus/'
@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?.length then next 404; return

  render-css = (file-name, cb) ->
    if file-name in cvars.acceptable-stylus-files # concat files
      fs.readFile "app/stylus/#{file-name}", (err, buffer) ->
        if err then cb err
        options =
          compress: true
        stylus(buffer.to-string!, options)
          .define \cache_url  cvars.cache_url
          .define \cache2_url cvars.cache2_url
          .define \cache3_url cvars.cache3_url
          .define \cache4_url cvars.cache4_url
          .define \cache5_url cvars.cache5_url
          .set \paths ['app/stylus']
          .use fluidity!
          .render cb
    else
      cb 404

  async.map files, render-css, (err, css-blocks) ->
    if err is 404
      return next 404
    else if err
      return next err
    else
      res.content-type 'css'
      caching-strategies.lastmod res, cvars.process-start-date, 7200
      res.send css-blocks.join "\n"
