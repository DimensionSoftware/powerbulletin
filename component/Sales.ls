require! {
  lodash
  Component: yacomponent
  \./ParallaxButton.ls
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

debounce = lodash.debounce _, 250

module.exports =
  class Sales extends Component
    hostname = if process.env.NODE_ENV is \production then \.powerbulletin.com else \.pb.com
    template: templates.Sales
    init: ->
      # mandatory state
      @local \hostname, hostname
      @local \subdomain ''

      # init children
      do ~>
        on-click = ~>
          console.log \created: + subdomain
          subdomain   = @local \subdomain
          @@$.post '/ajax/can-has-site-plz', {domain: subdomain+hostname}, ({errors, transient_owner}) ->
            if errors.length
              console.error errors
            else
              cookie-opts =
                domain: hostname
                expires: 1

              # set cookie so they are 'admin' of temporary site
              $.cookie \transient_owner, transient_owner, cookie-opts
              window.location = "http://#subdomain#hostname"
        locals = {title: 'Create Community'}
        @children =
          buy: new ParallaxButton {on-click, locals} \.Sales-create @
    on-attach: ->
      component = @
      $sa = @$.find(\.Sales-available)

      @check-subdomain-availability = @@$R((subdomain) ->
        @@$.get \/ajax/check-domain-availability {domain: subdomain+hostname} (res) ->
          $sa.remove-class 'success error'
          if res.available
            component.children.buy.enable!
            $sa.add-class \success
          else
            component.children.buy.disable!
            $sa.add-class \error
      ).bind-to @state.subdomain

      @$.on \keyup, \input.Sales-subdomain, debounce ->
        new-input = $(@).val!
        $ \input.Sales-subdomain .val new-input # update all inputs
        unless new-input is component.local(\subdomain)
          # only signal changes on _different_ input
          component.state.subdomain new-input
    on-detach: ->
      sh.r-unbind @check-subdomain-availability
      delete @check-subdomain-availability
      @$.off \keyup \input.Sales-subdomain
