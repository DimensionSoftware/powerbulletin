define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates}    = require \../build/component-jade
{show-tooltip} = require \../client/client-helpers

module.exports =
  class MiniSiteList extends Component
    template: templates.MiniSiteList

    init: ->

    on-attach: ~>
      @$.find('a.onclick-first-site').click (ev) ~>
        @@$.fancybox.close!
        window.scroll-to-top!
        set-timeout (->
          const sr = @@$ \.SiteRegister:first
          show-tooltip (sr.find \.tooltip), 'Name your community here!'
          sr.find \.SiteRegister-subdomain .focus!), 400ms
