define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Pins
  \./MenuSummary
}

{show-info, storage} = require \../client/client-helpers if window?

# XXX rename Homepage -> Layout-Split-Horizontal?

module.exports =
  class Homepage extends PBComponent
    init: ->
      # add children
      @children =
        #pins:    new Pins {locals:@locals!} \.Pins @
        summary: new MenuSummary {locals:@locals!} \.MenuSummary @

    on-attach: ->
      const seen-intro = "#{window.user?id}-home-intro"
      unless storage.get seen-intro
        storage.set seen-intro, true
        show-info 0,
          ['.Homepage, .menu .row', '<b>Welcome!</b> Forum Activity Shows Here in Realtime'],
          #['.tools, .tools li', 'Pull Down the Admin Menu and Get Your Community Started!']

# vim: fdm=marker
