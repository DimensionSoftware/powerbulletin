define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  lodash
  Component: yacomponent
  \./Auth
  \./SiteRegister
  \./MiniSiteList
  ch: \../client/client-helpers
  sh: \../shared/shared-helpers
}
{show-tooltip} = require \../client/client-helpers
{templates}    = require \../build/component-jade

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
      @scroll-to-top window

      @@$R((subdomain) ~>
        for c in [@children.register-top, @children.register-bottom]
          #unless subdomain is c.local(\subdomain)
          c.update-subdomain subdomain
      ).bind-to @state.subdomain

      @@$ \.onclick-my-sites .click @show-my-sites
      @@$ \#start_now .click ~># @scroll-to-top window; @@$ '.SiteRegister-create button:first' .click!
        @scroll-to-top window
        const sr = @@$ \.SiteRegister:first
        show-tooltip (sr.find \.tooltip), 'Name your community here!'
        set-timeout (-> sr.find \.SiteRegister-subdomain .focus!), 100ms
      #{{{ animate build-in & initial focus
      set-timeout (-> # bring in register
        $ \#register_top  .add-class \show
        $ \.SiteRegister-subdomain:first .focus!
        set-timeout (-> # ...and action!
          $ '.SiteRegister h3' .transition {opacity:1, x:-30px}, 350ms
          set-timeout (-> # build-in "Why you'll love" features last
            $ \#features .transition {opacity:1}, 1400ms), 1200ms), 100ms), 800ms
      #}}}

    login: (user) ->
      # use user later
      @$.find 'li.auth a.onclick-login' .hide!
      @$.find 'li.auth a.onclick-logout' .show!
      @$.find 'li.my-sites' .show!
      @$.find 'li.community' .hide!
      set-timeout (~> @show-my-sites!), 10ms # yield (for tha smoothness)

    logout: ->
      @$.find 'li.auth a.onclick-login' .show!
      @$.find 'li.auth a.onclick-logout' .hide!
      @$.find 'li.community' .show!
      @$.find 'li.my-sites' .hide!

    show-my-sites: ~>
      return if $('#auth:visible .register').length #guard
      <~ ch.lazy-load-fancybox
      $div = $ '<div/>'
      r <~ @@$.get '/ajax/sites-and-memberships'
      if r.success
        msl = new MiniSiteList({locals: r}, $div)
        $.fancybox.open $div
      else
        # error
        #
    scroll-to-top: ->
      unless @@$ \window .scroll-top is 0 # scroll to top
        @@$ 'html,body' .animate {scroll-top:0}, 50ms

    on-detach: -> @$.off!

#
# vim:fdm=marker
