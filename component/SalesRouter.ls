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
        res.json {res.locals}
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
        @navigate parse-path(History.get-page-url!), null

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

      klass-name = surl-mapping[type]
      css-class = "#{klass-name}-root"
      css-sel   = ".#css-class"
      only-attach = false

      finish = (klass) ~>
        c =
          if @top-components[klass-name] # component is already on page
            @top-components[klass-name]
          else
            if @@$(css-sel).length
              only-attach := true # component is on page from a server-side html render, only attach
            else
              root-el = @@$("<div class=\"#css-class\"/>") # root for component, never been on page before
              b.append root-el
            @top-components[klass-name] = new klass {-auto-render, -auto-attach, locals}, root-el

        if @is-client and not locals
          # fetch from server
          locals <- @@$.get url, {_surf:1}

          c.detach!
          c.locals locals
          c.render! unless only-attach
          c.attach!
          cb!
        else
          c.detach!
          c.locals locals
          c.render! unless only-attach
          c.attach!
          cb!

      if @is-client
        require ["../component/#klass-name"], finish
      else
        klass = require "./#klass-name"
        finish klass
