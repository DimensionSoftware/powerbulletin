__        = require 'underscore'
mutant    = require './mutant'

unpick = (obj, keys) -> # strip unnecessary values from mutate phase
  locals = __.clone obj
  for key in keys
    delete locals[key]
  locals

export mutant-layout = (jade-layout, mutants) ->
  fn = (req, res, next) ->
    if req.query._surf then req.surfing = true
    res.local 'q', req.param('q') or '' # layout query string

    res.mutant = (template_nm, opts={}) ->
      locals =
        if opts.locals # passed in own
          opts.locals
        else if opts.pick
          __.pick res._locals, opts.pick
        else if opts.unpick
          unpick res._locals, opts.unpick
        else # use express locals
          res._locals

      if req.surfing
        data = {locals:locals, mutant:template_nm}
        delete data.locals.req
        res.json data

      else
        res.local 'initial_mutant', template_nm
        res.local 'query', req.query
        res.render "#{jade_layout}.jade", {locals: locals, layout:false}, (err, base_html) ->
          if err then return next(err)

          mutant.run mutants[template_nm], locals:locals, html: base_html, (err, html) ->
            if err then return next(err)

            res.contentType 'html'
            res.send html
    next()

  # tag this middleware as surfable so that we can grab the right regexps to pass down to the client
  fn.surfable = true
  fn
