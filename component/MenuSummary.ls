define = window?define or require(\amdefine) module
require, exports, module <- define
require! {
  \./PBComponent
}

module.exports =
  class MenuSummary extends PBComponent
    init: ->
      # defaults

    on-attach: ->

# vim: fdm=marker
