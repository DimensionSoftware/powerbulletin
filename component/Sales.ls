require! {
  lodash
  \./Component.ls
  \./ParallaxButton.ls
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

debounce = lodash.debounce _, 250

module.exports =
  class Sales extends Component
    component-name: \Sales
    template: templates.Sales
    init: ->
      # mandatory state
      @state.subdomain ||= @@$R.state ''
      @local \hostname, if process.env.NODE_ENV is \production then \.powerbulletin.com else \.pb.com

      # init children
      do ~>
        on-click = ~>
          console.log \created: + subdomain
          subdomain   = @local \subdomain
          hostname = @local \hostname
          @@$.post '/ajax/can-has-site-plz', {subdomain}, ({errors, transient_owner}) ->
            if errors.length
              console.error errors
            else
              cookie-opts =
                domain: hostname
                expires: 1

              # set cookie so they are 'admin' of temporary site
              $.cookie \transient_owner, transient_owner, cookie-opts
              window.location = "http://#{subdomain}"
        locals = {title: 'Create Community'}
        @children =
          buy: new ParallaxButton {on-click, locals} \.Sales-create @
    on-attach: ->
      component = @
      $sa = @$.find(\.Sales-available)

      @check-subdomain-availability = @@$R((subdomain) ->
        @@$.get \/ajax/check-subdomain-availability {subdomain} (res) ->
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
