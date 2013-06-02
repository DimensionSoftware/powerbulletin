require! \./Component.ls
require! \./Sales.ls

{templates} = require \../build/component-jade.js

module.exports =
  class SalesApp extends Component
    component-name: \SalesApp
    template: templates.SalesApp
    children: ->
      [new Sales {} \body @]
