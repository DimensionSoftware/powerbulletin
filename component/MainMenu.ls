define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}

{templates} = require \../build/component-jade

module.exports =
  class MainMenu extends Component
    template: templates.MainMenu

    init: !~>
      @menu = @@$R((new-menu) ~>
        # TODO reactive menu
      ).bind-to @state.menu

    on-attach: !~>
      #{{{ Event Delegates
      #}}}

      ####  main  ;,.. ___  _
      # TODO
      # - render from site.config.menu

    on-detach: -> @$.off!

# vim:fdm=marker
