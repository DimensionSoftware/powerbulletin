require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    on-attach: !->
      $ document .on \click @unique-selector alert -> \buybuybuy
    on-detach: !-> #@$top.off!
      $ document .off \click @unique-selector
