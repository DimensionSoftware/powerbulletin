require! {
  fs
  async
  jade
  stylus
  fluidity
  __: \lodash
  pg: './postgres'
}

global <<< require './helpers'

db = pg.procs

@hello = (req, res) ->
  res.send "hello #{res.locals.remote-ip}!"

@homepage = (req, res, next) ->
  err, doc <- db.doc \misc, \homepage
  if err then return next(err)

  # all handlers should aspire to stuff as much non-personalized or non-time-sensitive info in a static doc
  # for O(1) retrieval (assuming hashed index map)
  doc.active = doc.forums[0] # TODO select real active
  res.locals doc

  # TODO fetch smart/fun combination of latest/best voted posts, posts & media

  # XXX: this should be abstracted into a pattern, middleware or pure function
  caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<<  res.locals.site), 7200
  res.content-type \html
  res.mutant \homepage

@forum = (req, res, next) ->
  finish = (doc) ->
    res.locals doc
    caching-strategies.etag res, sha1(JSON.stringify __.clone(req.params) <<< res.locals.site), 7200
    res.mutant \forum

  # parse url
  parts = forum-path-parts req.path
  if parts?.length > 1 # thread
    err, doc <- db.doc \misc, \homepage
    if err then return next err

    if doc?.forums?.length # store active
      doc.active = head filter (.slug is req.params.forum), doc.forums

    finish doc
  else # forum
    forum-slug = '/' + parts[0].join('/')
    err, fdoc <- db.forum-doc-by-slug forum-slug
    if err then return next err
    if !fdoc then return next(404)
    #XXX: maybe for optimization make this an index in the future
    fdoc.active = fdoc.forums[0] # TODO select real active
    finish fdoc

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
      caching-strategies.etag res, sha1(body), 7200
      res.content-type 'css'
      res.send body
#}}}

# vim:fdm=marker
