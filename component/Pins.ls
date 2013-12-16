define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
require \jqueryMasonry
{throttle}  = require \lodash
{templates} = require \../build/component-jade

const max-retry = 3failures

module.exports =
  class Editor extends Component
    template: templates.Pins

    init: ->
      # defaults

    on-attach: ->
      ####  main  ;,.. ___  _
      try # reflow masonry content
        window.$ \.homepage .masonry(
          item-selector: \.post
          is-animated:   true
          animation-options:
            duration: 100ms
          is-fit-width:  true
          is-resizable:  true).bind-resize!

    on-detach: ~> # XXX ensure detach is called
      # cleanup
      try window.$ \.homepage .masonry(\destroy)
      @$.off!remove!

# vim: fdm=marker
