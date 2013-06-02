require! \./Component.ls
require! \./Sales.ls

{templates} = require \../build/component-jade.js

module.exports =
  class SalesLayout extends Component
    component-name: \SalesLayout
    template: templates.SalesLayout
    children: ->
      [new Sales {} \body @]
