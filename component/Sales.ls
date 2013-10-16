define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  lodash
  Component: yacomponent
  \./SiteRegister
  sh: \../shared/shared-helpers
}
{templates} = require \../build/component-jade

debounce = lodash.debounce _, 250ms

module.exports =
  class Sales extends Component
    template: templates.Sales
    init: ->
      # mandatory state
      @local \subdomain ''  # make sure reactive variable exists

      # init children
      @children =
        register-top: new SiteRegister {locals: {subdomain: @state.subdomain}}, \#register_top, @
        register-bottom: new SiteRegister {locals: {subdomain: @state.subdomain}}, \#register_bottom, @

    on-attach: ->
      @@$R((subdomain) ~>
        for c in [@children.register-top, @children.register-bottom]
          #unless subdomain is c.local(\subdomain)
          c.update-subdomain subdomain
      ).bind-to @state.subdomain

      #{{{ animate build-in & initial focus
      set-timeout (-> # bring in register
        icon = $ \.logo-icon
        icon.transition {opacity:1, x:\0px, y:\0px, rotate:\0deg}, 700ms, \easeOutExpo
        $ \#register_top  .add-class \show
        $ \.SiteRegister-subdomain:first .focus!
        set-timeout (-> # ...and action!
          $ '.SiteRegister h3' .transition {opacity:1, y:30px}, 400ms
          icon.add-class \hover-around
          set-timeout (-> # build-in features last
            $ \#features .transition {opacity:1}, 1200ms), 1000ms), 100ms), 500ms

      unless $ window .scroll-top is 0 # scroll to top
        $ 'html,body' .animate {scroll-top:0}, 300ms, \easeOutExpo
      #}}}

    on-detach: -> @$.off!

# vim:fdm=marker
