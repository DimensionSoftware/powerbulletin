define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  surl: \../shared/sales-urls
  \./PBComponent
  \./SuperAdminUsers
  \./SuperAdminSites
}

mod-info =
  mod-users: {klass: SuperAdminUsers, url: surl.gen(\superUsers)}
  mod-sites: {klass: SuperAdminSites, url: surl.gen(\superSites)}

for mname, mi of mod-info
  mi.css-class = "SuperAdmin-#mname"
  # add css class to anchor as well and use that for click handlers

module.exports =
  class SuperAdmin extends PBComponent
    init: ->
      # @mods are special children
      # set them up based on mod-info above
      @mods = {}
      for mname, mi of mod-info
        m = new mi.klass {locals: @state}, "div.#{mi.css-class}", @
        m <<< {mi.css-class, mi.url, mod-name: mname}
        @mods[mname] = m

      @state.mods = @@$R ~> @mods # expose mods to jade

      @children = {}
      @children <<< @mods # mods are a subset of children

      @@$R((route) ~>
        # route is one of [\super, \superSites, \superUsers]
        # in future:
        # {type: \super, id: 1}, {type: \superSites}]
        {
          super       : ~> @activate-mod \modUsers
          super-sites : ~> @activate-mod \modSites
          super-users : ~> @activate-mod \modUsers
        }[route]!
      ).bind-to @state.route
    mutate: ($dom) ->
      # setup anchor points for mods based on inference
      for mname, mi of mod-info
        $dom.find('.SuperAdmin-content').append("<div class=\"#{mi.css-class}\">")
    activate-mod: (mname) ->
      mod = @mods[mname] or throw new Error "cannot activate invalid SuperAdmin module name: #mname"
      if @is-client # we don't really give a damn about the initial server-side render for this component ;)
        @$.find(".SuperAdmin-content > div").hide!
        @$.find(".SuperAdmin-content > div.#{mod.css-class}").show!
    on-attach: ->
      @state.route! # touch route reactive-var on initial load
