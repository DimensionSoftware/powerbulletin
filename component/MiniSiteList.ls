define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

module.exports =
  class MiniSiteList extends PBComponent

    init: ->

    on-attach: ~>
      @$.find('a.onclick-first-site').click ->
        @@$.fancybox.close!
        @@$ \#start_now .click!
