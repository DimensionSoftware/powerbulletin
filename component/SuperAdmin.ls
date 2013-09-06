define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./SuperAdminUsers
  \./SuperAdminSites
}
{templates} = require \../build/component-jade

mod-info =
  mod-users: {klass: SuperAdminUsers}
  mod-sites: {klass: SuperAdminSites}

for mname, mi of mod-info
  mi.css-class = "SuperAdmin-#mname"
  # add css class to anchor as well and use that for click handlers

module.exports =
  class SuperAdmin extends Component
    template: templates.SuperAdmin
    init: ->
      # default locals
      @local \activeMod, \modUsers unless @local(\activeMod)

      # @mods are special children
      # set them up based on mod-info above
      @mods = {}
      for mname, mi of mod-info
        m = @mods[mname] = new mi.klass {}, "div.#{mi.css-class}", @
        m <<< {mi.css-class}

      @state.mods = @@$R ~> @mods # expose mods to jade

      @children = {}
      @children <<< @mods # mods are a subset of children
    mutate: ($dom) ->
      # setup anchor points for mods based on inference
      for mname, mi of mod-info
        $dom.find('.SuperAdmin-content').append("<div class=\"#{mi.css-class}\">")
    on-attach: ->
      for m in @mods
        console.warn \WANK, ".SuperAdmin-content > div.#{m.css-class}"
        @$.on \click, ".SuperAdmin-nav > a.#{m.css-class}", ~>
          @$.find('.SuperAdmin-content > div').hide!
          @$.find(".SuperAdmin-content > div.#{m.css-class}").show!
