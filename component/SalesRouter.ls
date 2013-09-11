define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  surl: \../shared/sales-urls
  surl-mapping: \../shared/sales-url-mappings
}

{templates} = require \../build/component-jade

module.exports =
  class SalesRouter extends Component
    # only intended to be used in express
    @middleware = (req, res, next) ->
      {incomplete, type} = surl.parse req.url
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
        err <- sr.navigate(req.url, res.locals)
        if err then return next err

        body = sr.html(false)

        res.content-type \html
        res.send body
    template: templates.SalesRouter # shared with forum app
    init: ->
      @local \stylesheets, ["/dynamic/css/master-sales.styl?#{CHANGESET}"]

      # top components
      @top-components = {}

    # client: load any dependencies and navigate to url in component and navigate window history
    # server: load any dependencies and navigate to url in component
    navigate: (url, locals, cb) ->
      {type} = surl.parse url
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
              b = if @is-client then @@$('body') else @$.find('body')
              root-el = @@$("<div class=\"#css-class\"/>") # root for component, never been on page before
              b.append root-el
            @top-components[klass-name] = new klass {-auto-render, -auto-attach}, root-el

        if @is-client and not locals
          # fetch from server
          r1,r2,r3 <- @@$.get url, {+_surf}
          # given locals instantiate with locals here
          # XXX: do something real with the response
          console.warn \WHEE r1,r2,r3
          # locals from ajax
          locals = {}
          locals <<< cvars
          c.detach!
          c.locals locals
          c.render! unless only-attach
          c.attach!
          cb!
        else
          console.warn "trying to attach #klass-name on server-side"
          locals <<< cvars
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
