require! Component: yacomponent
require! \./SalesApp
require! \./Auth

{templates} = require \../build/component-jade

module.exports =
  class SalesLoader extends Component
    template: templates.SalesLoader # shared with forum app
    init: ->
      @children =
        sales: new SalesApp {} \body @
