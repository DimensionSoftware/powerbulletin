define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates}    = require \../build/component-jade
{show-tooltip} = require \../client/client-helpers

module.exports =
  class ChatPanel extends Component
    template: templates.ChatPanel

    init: ->

    show: ->

    hide: ->

    resize: ->

