require! \./Component.ls
require! \./ParallaxButton.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    ->
      super ...
      on-click = -> alert \booya_purchase
      @children =
        checkout-button: new ParallaxButton {on-click, locals:{title: 'CHECKOUT'}}, \.Buy-checkout, @
