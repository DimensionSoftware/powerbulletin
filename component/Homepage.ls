define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Pins
  \./MenuSummary
}

# XXX rename Homepage -> Layout-Split-Horizontal?

module.exports =
  class Homepage extends PBComponent
    init: ->
      # add children
      @children =
        pins:    new Pins {locals:@locals!} \.Pins @
        summary: new MenuSummary {locals:@locals!} \.MenuSummary @

# vim: fdm=marker
