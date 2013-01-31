__     = require \lodash
mutant = require './mutant'

unpick = (obj, keys) -> # strip unnecessary values from mutate phase
  locals = __.clone obj
  for key in keys
    delete locals[key]
  locals

export mutant-layout = (jade-layout, mutants) ->
  fn = (req, res, next) ->
    if req.query._surf then req.surfing = true
    res.locals.q = req.param(\q) or '' # layout query string

    res.mutant = (template-nm, opts={}) ->
      locals =
        if opts.locals # passed in own
          opts.locals
        else if opts.pick
          __.pick res.locals, opts.pick
        else if opts.unpick
          unpick res.locals, opts.unpick
        else # use express locals
          res.locals

      if req.surfing
        data =
          locals:locals
          mutant:template-nm
        delete data.locals.req
        res.json data
      else
        res.locals.initial-mutant = template-nm
        res.locals.query = req.query
        res.render "#{jade-layout}.jade", {locals: locals, layout:false}, (err, base-html) ->
          if err then return next err
          mutant.run mutants[template-nm], locals:locals, html: base-html, (err, html) ->
            if err then return next err
            res.content-type \html
            res.send html
    next!

  # tag this middleware as surfable so that we can grab the right regexps to pass down to the client
  fn.surfable = true
  fn
