if window?
  true
else
  jsdom = require 'jsdom'
  jade = require 'jade'

  gen_dom_window = (html, cb) ->
    scripts = ["cache/web/js/jquery-1.7.1.min.js"]

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

  onLoad = template.onLoad || ((w, cb) -> cb(null))
  onInitial = template.onInitial || ((w, cb) -> cb(null))
  onMutate = template.onMutate || ((w, cb) -> cb(null))

  if window?
    if initial_run
      onLoad.call params, window, (err) ->
        if err then return cb(err)
        onInitial.call params, window, cb

    else
      window.renderJade = (tmpl_name, cb) ->
        $.get "/templates/#{tmpl_name}", (funtxt) ->
          # bring runtime into scope, assumes runtime is attached to window (by loading runtime.js)
          jade = window.jade
          jade_tmpl = eval "#{funtxt} anonymous"
          cb(null, jade_tmpl(params))

      window.marshal = (key, val) ->
        window[key] = val

      # render static jade template, followed by dynamic mutator template
      template.static.call params, window, (err) ->
        if err then return cb(err)

        onLoad.call params, window, (err) ->
          if err then return cb(err)
          onMutate.call params, window, cb

  else if html
    # playskool pretend server-side window
    gen_dom_window html, (err, window) ->
      if err then return cb(err)

      window.renderJade = (tmpl_name, cb) ->
        jade.renderFile "./views/#{tmpl_name}.jade", params, cb

      window.marshal = (key, val) ->
        #window.$('body').append("<script>window['#{key}'] = #{JSON.stringify(val)};</script>")
        s = window.document.createElement('script')
        window.$(s).attr('type', 'text/javascript')
        window.$(s).text("window['#{key}'] = #{JSON.stringify(val)};")
        window.document.body.appendChild(s)

      template.static.call params, window, (err) ->
        if err then return cb(err)

        # mutating / loading of jquery already accomplished, don't pollute html page load
        window.$('script.jsdom').remove()

        # finally return html
        cb(null, "<!doctype html>\n" + window.document.outerHTML)
  else
    throw new Error("need html for serverside")

