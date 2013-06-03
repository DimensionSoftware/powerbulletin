require! \./Component.ls
require! \./ParallaxButton.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Sales extends Component
    component-name: \Sales
    template: templates.Sales
    ->
      super ...
      backup-buy = ->
        alert "sorry our developers are lazy and haven't implemented this yet"
      @children =
        buy: new ParallaxButton {on-click: (-> if window.do-buy then window.do-buy! else backup-buy!), locals:{title: 'BUY'}} \.Sales-buy @
