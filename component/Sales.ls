require! {
  lodash
  Component: yacomponent
  \./ParallaxButton.ls
  \./SiteRegister.ls
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

debounce = lodash.debounce _, 250

module.exports =
  class Sales extends Component
    template: templates.Sales
    init: ->
      # mandatory state
      @local \subdomain ''  # make sure reactive variable exists

      # init children
      @children =
        register-top: new SiteRegister {locals: {subdomain: @state.subdomain}}, \#register-top, @
        register-bottom: new SiteRegister {locals: {subdomain: @state.subdomain}}, \#register-bottom, @

    on-attach: ->
      @@$R((subdomain) ~>
        for c in [@children.register-top, @children.register-bottom]
          #unless subdomain is c.local(\subdomain)
          c.update-subdomain subdomain
      ).bind-to @state.subdomain

