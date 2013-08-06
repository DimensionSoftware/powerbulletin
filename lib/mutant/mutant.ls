if window?
  true
else
  require! {
    #jsdom
    cheerio
  }

  use-jsdom = false

  dom-window = (html, cb) ->
    scripts =
      \../../public/local/jquery-1.9.1.min.js
      \../../node_modules/reactivejs/src/reactive.js

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

  if template.static?prepare and template.static?draw
    # static phase split into prepare and draw, the rest of the phases, being on the client, are programmer defined
    # obviously on the server side the phases are meaningless, but on the client, they are very meaningful
    # NEW way of doing things
    prepare = template.static?prepare || ((w, cb) -> cb!)
    raw-draw = template.static?draw || ((w, cb) -> cb!)
  else
    # temporary shim so all are not forced to take advantage immediately
    # OLD way of doing things

    # prepare is a noop as a shim for the 'old' way here
    prepare = ((w, cb) -> cb!)

    # draw is unlikely to happen in under 16ms, and hence will not take advantage of
    # request-animation-frame because extra draws will still occur
    # 
    # if this is the case then refactor to take advantage of above branch by defining 'draw' and 'prepare'
    # if you can get 'draw' to happen in under 16ms then great!
    raw-draw = template.static || ((w, cb) -> cb!)

  if raf = window?request-animation-frame
    # wrap draw if window.request-animation-frame exists
    draw = (w, cb) ->
      params = @
      raf ->
        beg = new Date
        raw-draw.call params, w, ->
          end = new Date
          cb!
          # kick off logging async so it doesn't slow down raf callback
          set-timeout(_, 1) ->
            dur = end - beg
            if true#dur > 16ms
              info = "request-animation-frame took #{dur}ms in mutant static draw phase"
              console.warn info
  else
    draw = raw-draw


  on-load         = template.on-load         || ((w, cb) -> cb!)
  on-initial      = template.on-initial      || ((w, cb) -> cb!)
  on-mutate       = template.on-mutate       || ((w, cb) -> cb!)
  on-personalize  = template.on-personalize  || ((w, u, cb) -> cb!)

  require \../../build/client-jade.js # pre-built clientjade templates

  # like inner html, except super rice
  # mutant has lots of entropy so we can avoid the teardown performance hit
  # http://blog.stevenlevithan.com/archives/faster-than-innerhtml
  !function replace-html $el, html
    if window?
      el = $el.0
      new-el = el.clone-node false
      new-el.inner-HTML = html
      el.parent-node.replace-child new-el, el
    else
      $el.html html

  render-mutant = (id, tmpl) ->
    replace-html $("\##id"), jade.templates[tmpl](params)

  render = (t) -> jade.templates[t](params)

  if window?
    window <<< {render, replace-html}

    if initial_run
      err <- on-load.call params, window
      if err then return cb(err)
      err <- on-initial.call params, window
      if err then return cb(err)
      if user
        on-personalize.call params, window, user, cb
      else
        cb!

    else
      # render static jade template, followed by dynamic mutator template
      window.render-mutant = (target, tmpl) ->
        jade.render window.document.get-element-by-id(target), tmpl, params

      window.marshal = (key, val) ->
        window[key] = val

      err <- prepare.call params, window
      if err then return cb(err)

      has-draw = !!template.static?draw

      # if the mutant has a draw phase specified, use raf, otherwise skip raf
      err <- (if has-draw then draw else raw-draw).call params, window
      if err then return cb(err)

      err <- on-load.call params, window
      if err then return cb(err)
      err <- on-mutate.call params, window
      if err then return cb(err)
      if user
        on-personalize.call params, window, user, cb
      else
        cb!

  else if html
    # playskool pretend server-side window
    var-statements = []
    marshal = (key, val) ->
      if val isnt void then var-statements.push "window['#{key}']=#{JSON.stringify(val)}"

    run-static = (window) ->
      window <<< {render, replace-html}
      err <- prepare.call params, window
      if err then return cb err

      draw.call params, window, (err) ->
        if err then return cb err
        if use-jsdom # don't pollute html page load
          window.$('script.jsdom').remove!
          # append marshalled vars
          s = window.document.createElement \script
          window.$ s .attr('type', 'text/javascript')
          window.$ s .text var-statements.join(';')
          window.document.body.appendChild s
        else
          $ \body .append "<script type=\"text/javascript\">#{var-statements.join \;}</script>"
        # finally return html
        cb null if use-jsdom then "<!doctype html>#{window.document.outerHTML}" else $.html!

    if use-jsdom # jslowdom
      dom-window html, (err, jsdom-window) ->
        if err then return cb err
        jsdom-window.marshal = marshal
        jsdom-window.render-mutant = (target, tmpl) ->
          jade.render jsdom-window.document.get-element-by-id(target), tmpl, params
        run-static jsdom-window
    else
      $ = cheerio.load html
      run-static {marshal:marshal, render-mutant:render-mutant, $:$}
  else
    throw new Error("need html for serverside")

# surfable routes populated now that we have declared all routes
is-surfable = (r) ->
  r.callbacks.some( (m) -> m.surfable )
@surfable-routes = (app) ->
  [r.regexp.to-string! for r in app.routes.get when is-surfable r]
