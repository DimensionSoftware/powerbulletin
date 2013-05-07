if window?
  true
else
  require! {
    jsdom
  }

  dom-window = (html, cb) ->
    scripts = ['../../public/local/jquery-1.9.1.min.js']

    jsdom_opts = {html, scripts}

    jsdom_done = (err, window) ~>
      if err then return cb(err)

      window.$ = window.jQuery
      cb(null, window)

    jsdom.env jsdom_opts, jsdom_done

@run = (template, opts, cb = (->)) ->
  /*
  run returns void because it mutates the window object

  on the server side we need to know the base html before we can mutate it

  on the client side the callback returns nothing because the dom has been mutated already
  on the server side the callback will return html

  templates are objects with up to four methods:
  static, onLoad, onInitial, onMutate

  static is client or serverside and this phase is purely for html dom tree creation/manipulation

  onLoad happens when a mutant template is run, regardless of whether it is the initial pageload, or a mutation

  onInitial only happens on an initial pageload (not on mutation)

  onMutate only happens on a mutation (not on an initial pageload)
  */

  # initial pagelaod, only run dynamic
  initial_run = opts.initial
  # parameters for static pageload
  params = opts.locals || {}
  # specify base html if we are serverside
  html = opts.html

  user = opts.user

  onLoad         = template.onLoad        || ((w, cb) -> cb(null))
  onInitial      = template.onInitial     || ((w, cb) -> cb(null))
  onMutate       = template.onMutate      || ((w, cb) -> cb(null))
  onPersonalize  = template.onPersonalize || ((w, u, cb) -> cb(null))

  require '../../app/views/templates.js' # pre-built clientjade templates

  if window?
    if initial_run
      err <- onLoad.call params, window
      if err then return cb(err)
      err <- onInitial.call params, window
      if err then return cb(err)
      if user
        err <- onPersonalize.call params, window, user
        if err then return cb(err)
        if cb then cb!

    else
      # render static jade template, followed by dynamic mutator template
      window.render-mutant = (target, tmpl) ->
        cb null, jade.render window.document.get-element-by-id(target), tmpl, params

      window.marshal = (key, val) ->
        window[key] = val

      err <- template.static.call params, window
      if err then return cb(err)
      err <- onLoad.call params, window
      if err then return cb(err)
      err <- onMutate.call params, window
      if err then return cb(err)
      if user
        err <- onPersonalize.call params, window, user
        if err then return cb(err)
        if cb then cb!

  else if html
    # playskool pretend server-side window
    dom-window html, (err, window) ->
      if err then return cb err

      window.render-mutant = (target, tmpl) ->
        jade.render window.document.get-element-by-id(target), tmpl, params

      var-statements = []
      window.marshal = (key, val) ->
        var-statements.push "window['#{key}']=#{JSON.stringify(val)}"

      template.static.call params, window, (err) ->
        if err then return cb err

        # mutating / loading of jquery already accomplished, don't pollute html page load
        window.$('script.jsdom').remove!

        # append marshalled vars
        s = window.document.createElement \script
        window.$ s .attr('type', 'text/javascript')
        window.$ s .text var-statements.join(';')
        window.document.body.appendChild s

        # finally return html
        cb null "<!doctype html>#{window.document.outerHTML}"
  else
    throw new Error("need html for serverside")

# surfable routes populated now that we have declared all routes
is-surfable = (r) ->
  r.callbacks.some( (m) -> m.surfable )
@surfable-routes = (app) ->
  [r.regexp.to-string! for r in app.routes.get when is-surfable r]
