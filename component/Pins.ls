define = window?define or require(\amdefine) module
require, exports, module <- define
require! \./PBComponent

module.exports =
  class Pins extends PBComponent
    on-attach: ->
      <- requirejs [\jqueryMasonry] # lazy
      ####  main  ;,.. ___  _
      try # reflow masonry content
        @@$ \.homepage .masonry(
          item-selector: \.post
          is-animated:   true
          is-fit-width:  true
          is-resizable:  true
          animation-options:
            duration: 100ms).bind-resize!

    on-detach: ~> # XXX ensure detach is called
      super ...
      # cleanup
      try @@$ \.homepage .masonry(\destroy)

# vim: fdm=marker
