define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Pins
  \./ThreadSummary
}

# XXX rename Homepage -> Layout-Split-Horizontal?

module.exports =
  class Homepage extends PBComponent
    init: ->
      # add children
      console.log \locals:, @locals!
      @children =
        pins:    new Pins {locals:@locals!} \.Pins
        summary: new ThreadSummary {locals:@locals!} \.ThreadSummary

# vim: fdm=marker
