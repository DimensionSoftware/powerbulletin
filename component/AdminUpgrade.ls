require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class AdminUpgrade extends Component
    template: templates.AdminUpgrade
