require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    attach: !-> #@$top.on
    detach: !-> #@$top.off!
