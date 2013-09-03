define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  \./SuperAdminUsers
}
{templates} = require \../build/component-jade

module.exports =
  class SuperAdmin extends Component
    template: templates.SuperAdmin
    init: ->
      # @mods are special components designed to work
      # within this component
      @mods = {
        mod-users: new SuperAdminUsers {} \.SuperAdmin-modUsers @
      }

      @children = {} # paginator will go here soon
      @children <<< @mods # mods are a subset of children

      @state.mods = @@$R ~> @mods # expose mods to jade
    mutate: ($dom) ->
      # setup anchor points for mods based on inference
      for mname, m of @mods
        $dom.find('.SuperAdmin-content').append("<div class=\"SuperAdmin-#mname\">")
