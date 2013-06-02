require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Sales extends Component
    component-name: \Sales
    template: templates.Sales
