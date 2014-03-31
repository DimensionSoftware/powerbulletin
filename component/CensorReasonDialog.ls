define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

module.exports =
  class CensorReasonDialog extends PBComponent

    init: ->

    on-attach: ->

    close: ->

    submit: ->
