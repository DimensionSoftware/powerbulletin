define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  sh: \../shared/shared-helpers
  surl: \../shared/sales-urls
  surl-mapping: \../shared/sales-url-mappings
}

require \jqueryHistory if window?

{templates} = require \../build/component-jade

function kill-trailing-slash path
  if path.match /\/$/
    # remove trailing slash if it exists
    path.slice(0, -1)
  else
    path

function parse-path url
  parser = sh.parse-url url
  path = parser.pathname
  if path is \/
    \/
  else
    # no trailing slash to remove
    kill-trailing-slash path

module.exports =
  class SalesRouter extends Component
    # only intended to be used in express
    @middleware = (req, res, next) ->
      path = sh.parse-url(req.url).pathname
      {incomplete, type} = surl.parse path
      return next! if incomplete

      # this little hack hides this dependency from require.js static analysis tehehe
      handlers = [\../app/sales-component-handlers].map(require).0 unless window?

      # run component handler first
      # which should populate locals
      # a fallback handler is provided in case a component handler was not defined yet
      # the fallback handler does _nothing_
      component-handler = handlers[type] or ((req, res, next) -> next!)
      err <- component-handler req, res
      if err then return next err

      if req.query._surf

        # json render
        res.json({} <<< res.locals)
      else
        sr = new SalesRouter {locals: cvars}

        # html render
        err <- sr.navigate(req.url, {} <<< res.locals)
        if err then return next err

        body = sr.html(false)

        res.content-type \html
        res.send body
    template: templates.SalesRouter # shared with forum app
    init: ->
      @local \stylesheets, ["/dynamic/css/master-sales.styl?#{CHANGESET}"]

      # top components
      @top-components = {}
    on-attach: ->
      # bind history adapter
      History.Adapter.bind window, \statechange, ~>
        # surf to retrieve locals and navigate (second argument means surf instead of passing locals directly)
        {data} = History.get-state!

        # marking locals as null tells @navigate to fetch with surf instead
        locals = if Object.keys(data).length then data else null

        @navigate kill-trailing-slash(History.get-page-url!), locals

      # attach to existing dom if available on  attach/page-load
      # SalesRouter is intended to only be attached once, so this is fine!
      @navigate(window.location.pathname + window.location.search)

      # attach anchor/button hijacking, use data-href or href attribute
      dollarish = @@$
      click-handler = ->
        $el = dollarish @
        href = $el.data(\href) or $el.attr(\href)
        History.push-state null, null, href
        false

      @@$('body').on \click \a.mutant click-handler
      @@$('body').on \click \button.mutant click-handler

    # client: load any dependencies and navigate to url in component and navigate window history
    # server: load any dependencies and navigate to url in component
    navigate: (url, locals, cb = (->)) ->
      _url = url #DAFUQ?
      path = parse-path(url)
      {incomplete, type} = surl.parse path

      if incomplete
        throw new Error "cannot navigate to invalid path: #path"

      b = if @is-client then @@$('body') else @$.find('body')

      [klass-name, layout-klass-name, layout-root-sel] =
        surl-mapping[type] or throw new Error "no component mapping defined for route token: '#type'"
      css-class = "#{klass-name}-root"
      css-sel   = ".#css-class"

      finish = (klass, layout-klass) ~>
        only-attach = false

        # reap previous component only if going to a new top-level klass
        if klass-name isnt @last-klass-name and old-c = @top-components[@last-klass-name]
          delete @top-components[@last-klass-name]
          old-c.detach!
          # we remove parent instead if it exists, since it is the dynamic layout we injected from before
          (old-c.parent?$ or old-c.$).remove! # reap dom immediately
        @last-klass-name = klass-name

        reuse-component = false
        if c = @top-components[klass-name]
          # component already initialized from previous route, so we just touch the reactive 'route' local
          reuse-component = true
        else
          # instantiate since there is no instance yet...
          existing-root-el = @@$(css-sel)
          if existing-root-el.length
            only-attach = true # component is on page from a server-side html render, only attach
            root-el = existing-root-el
          else
            root-el = @@$("<div class=\"#css-class\"/>") # root for component, never been on page before
            b.append root-el

          make-component = (elr, parent) ->
            new klass {-auto-render, -auto-attach, locals: ({} <<< locals <<< {route: type})}, elr, parent

          if layout-klass
            # nest a component in a parent layout without coupling them together
            layout-c = new layout-klass {-auto-render, -auto-attach, locals: ({} <<< locals <<< {route: type})}, root-el
            nested-c = @top-components[klass-name] = make-component layout-root-sel, layout-c # layout-c is the parent of nested-c
            layout-c.children ||= {} # just in case there are other children in layout, we want to be nice
            layout-c.children <<< {content: nested-c} # mix our special child in (top-level component nested in layout)
            c = layout-c
          else
            c = @top-components[klass-name] = make-component root-el

        custom-reload = (l) ->
          if reuse-component
            # component already initialized from previous route, so we just touch the reactive 'route' local
            c.local \route, type
          else
            c.detach!
            c.locals l
            c.render! unless only-attach
            c.attach!

          # put url type in body class to trigger css transition
          b.attr(\class, null).add-class(type)


        if @is-client and not locals
          # fetch from server remotely
          __url = _url + (if _url.match(/\?/) then '&' else '?') + '_surf=1'
          remote-locals <- @@$.get __url
          custom-reload remote-locals
          cb!
        else
          custom-reload locals
          cb!

      if @is-client
        if layout-klass-name
          require ["../component/#klass-name", "../component/#layout-klass-name"], finish
        else
          require ["../component/#klass-name"], finish
      else
        klass = require "./#klass-name"
        layout-klass = require "./#layout-klass-name" if layout-klass-name
        finish klass, layout-klass
