require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    attach: !->
      @$top.on \click \h1 -> alert(\fuck)
    detach: !-> #@$top.off!
