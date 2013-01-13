require! {
  fs
  async
  stylus
  fluidity
  './helpers'
  vdb: './voltdb'
}

@homepage = (req, res, next) ->
  # TODO fetch smart/fun combination of latest/best voted posts, threads & media
  user =
    name       : \anonymous
    created_at : new Date!
  posts = for ii to 4
    date    : title-case elapsed-to-human-readable Math.random!*604800
    user    : user
    message : ellipse 'hello world!' 6
  topics = for i to 5 # dummy data
    title : \Test
    date  : title-case elapsed-to-human-readable Math.random!*31446925
    user  : user
    posts : posts
  res.locals.topics = topics

  # XXX: this should be abstracted into a pattern, middleware or pure function
  res.render \homepage, (err, body) ->
    if err then return next(err)

    caching-strategies.etag res, helpers.sha1(body), 7200
    res.content-type \html
    res.send body

@hello = (req, res) ->
  res.send "hello #{res.locals.remote-ip}"

#{{{ Asset serving handlers
cvars.acceptable-js-files = fs.readdir-sync 'public/js/'
@js = (req, res, next) ->
  r = req.route.params

  if r.file in cvars.acceptable-js-files
    (err, buffer) <- fs.read-file "public/js/#{r.file}"
    body = buffer.to-string!
    caching-strategies.etag res, helpers.sha1(body), 7200
    res.content-type \js
    res.send body
  else
    res.send 404, 404

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
