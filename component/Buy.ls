require! \./Component.ls
require! \./ParallaxButton.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    init: ->
      on-click = ~>
        data =
          number: @$.find(\.Buy-card-number).val!
          expiration: @$.find(\.Buy-card-expiration).val!
          code: @$.find(\.Buy-card-code).val!
        @@$.post "/ajax/checkout/#{@local(\product).id}", data, -> console.log ...arguments

      @children = {
        checkout-button: new ParallaxButton {on-click, locals:{title: 'CHECKOUT'}}, \.Buy-checkout, @
      }
