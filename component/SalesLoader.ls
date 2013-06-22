require! Component: yacomponent
require! \./SalesApp.ls

{templates} = require \../build/component-jade.js

module.exports =
  class SalesLoader extends Component
    template: templates.SalesLoader # shared with forum app
    init: ->
      @children =
        sales: new SalesApp {} \body @
