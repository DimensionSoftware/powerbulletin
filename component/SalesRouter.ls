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

function parse-path url
  parser = sh.parse-url url
  path = parser.pathname
  if path is \/
    \/
  else if path.match /\/$/
    # remove trailing slash if it exists
    path.slice(0, -1)
  else
    # no trailing slash to remove
    path

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
      err <- handlers[type] req, res
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
      History.Adapter.bind window, \statechange, ~>
        # surf to retrieve locals and navigate (second argument means surf instead of passing locals directly)
        {data} = History.get-state!

        # marking locals as null tells @navigate to fetch with surf instead
        locals = if Object.keys(data).length then data else null

        @navigate parse-path(History.get-page-url!), locals

    # client: load any dependencies and navigate to url in component and navigate window history
    # server: load any dependencies and navigate to url in component
    navigate: (url, locals, cb = (->)) ->
      path = parse-path(url)
      {incomplete, type} = surl.parse path

      if incomplete
        console.warn "cannot navigate to invalid path: #path"
        return cb!

      b = if @is-client then @@$('body') else @$.find('body')

      # put url type in body class
      b.attr(\class, null).add-class(type)

      [klass-name, layout-klass-name, layout-root-sel] = surl-mapping[type]
      css-class = "#{klass-name}-root"
      css-sel   = ".#css-class"
      only-attach = false

      finish = (klass, layout-klass) ~>
        if @top-components[klass-name] # component is already on page
          c = @top-components[klass-name]
        else
          existing-root-el = @@$(css-sel)
          if existing-root-el.length
            console.log "#klass-name: skipping render (already in DOM, only attaching)"
            only-attach := true # component is on page from a server-side html render, only attach
            root-el = existing-root-el
          else
            root-el = @@$("<div class=\"#css-class\"/>") # root for component, never been on page before

        make-component = (elr) ->
          new klass {-auto-render, -auto-attach, locals}, elr

        if layout-klass
          layout-component = new layout-klass {-auto-render, -auto-attach, locals}, root-el
          layout-component.children = { content: make-component layout-root-sel }
          c = layout-component
        else
          c ||= @top-components[klass-name] = make-component root-el

        b.append root-el

        custom-reload = (l) ->
          c.detach!
          c.locals l
          c.render! unless only-attach
          c.attach!

        if @is-client and not locals
          # fetch from server remotely
          remote-locals <- @@$.get url, {_surf:1}
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
