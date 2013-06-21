require! \./Component.ls
require! \./ParallaxButton.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    init: ->
      @local \cardNeeded, true if @local(\cardNeeded) is void

      on-click = ~>
        data =
          number: @$.find(\.Buy-card-number).val!
          expiration: @$.find(\.Buy-card-expiration).val!
          code: @$.find(\.Buy-card-code).val!
        @@$.post "/ajax/checkout/#{@local(\product).id}", data, ->
          console.log ...arguments

      @children = {
        checkout-button: new ParallaxButton {on-click, locals:{title: 'CHECKOUT'}}, \.Buy-checkout, @
      }
    on-attach: ->
      component = @
      @$.on \click \.Buy-change-card ->
        component.local \cardNeeded, true
        component.detach!render!attach!
        return false
    on-detach: ->
      @$.off!
