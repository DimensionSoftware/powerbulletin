require! {
  fs
  async
  stylus
  fluidity
  './data'
  './helpers'
  vdb: './voltdb'
}

@homepage = (req, res, next) ->
  err, doc <- data.homepage-doc
  if err then return next(err)

  # all handlers should aspire to stuff as much non-personalized or non-time-sensitive info in a static doc
  # for O(1) retrieval (assuming hashed index map)
  res.locals doc

  # TODO fetch smart/fun combination of latest/best voted posts, threads & media

  # XXX: this should be abstracted into a pattern, middleware or pure function
  res.render \homepage, (err, body) ->
    if err then return next(err)

    caching-strategies.etag res, helpers.sha1(body), 7200
    res.content-type \html
    res.send body

@hello = (req, res) ->
  res.send "hello #{res.locals.remote-ip}"

@register = (req, res) ->
  req.assert('login').is-alphanumeric!

  if errors = req.validation-errors!
    res.json {errors}
  else
    res.json req.body

cvars.acceptable-stylus-files = fs.readdir-sync 'app/stylus/'
@stylus = (req, res, next) ->
  r = req.route.params
  files = r.file.split ','
  if not files?.length then next 404; return

  render-css = (file-name, cb) ->
    if file-name in cvars.acceptable-stylus-files # concat files
      fs.read-file "app/stylus/#{file-name}", (err, buffer) ->
        if err then return cb(err)

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
    if err
      return next err
    else
      body = css-blocks.join "\n"
      caching-strategies.etag res, helpers.sha1(body), 7200
      res.content-type 'css'
      res.send body
#}}}

# vim:fdm=marker
