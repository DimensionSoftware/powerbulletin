define = window?define or require(\amdefine) module
require, exports, module <- define
require! \./PBComponent

module.exports =
  class ThreadSummary extends PBComponent
    init: ->
      # defaults

    on-attach: ->

# vim: fdm=marker
