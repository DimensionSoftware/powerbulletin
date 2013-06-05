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
    ->
      super ...
      # mandatory state
      @state.domain ||= @@$R.state ''

      # init children
      do ~>
        on-click = ->
          console.log \create-community
          window.do-buy!
          # XXX/TODO:  this should take you to admin control panel as soon as
          # community is created
        locals = {title: 'Create my community'}
        @children =
          buy: new ParallaxButton {on-click, locals} \.Sales-create @
    on-attach: ->
      component = @
      $sa = @$.find(\.Sales-available)

      @check-domain-availability = @@$R((domain) ->
        $.get \/ajax/check-domain-availability {domain} (res) ->
          $sa.remove-class 'success error'
          if res.available
            component.children.buy.enable!
            $sa.add-class \success
          else
            component.children.buy.disable!
            $sa.add-class \error
      ).bind-to @state.domain

      @$.on \keyup, \input.Sales-domain, debounce ->
        new-input = $(@).val!
        unless new-input is component.local(\domain)
          # only signal changes on _different_ input
          component.state.domain new-input
    on-detach: ->
      sh.r-unbind @check-domain-availability
      delete @check-domain-availability
      @$.off \keyup \input.Sales-domain
