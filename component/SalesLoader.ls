require! \./Component.ls
require! \./SalesApp.ls

{templates} = require \../build/component-jade.js

module.exports =
  class SalesLoader extends Component
    component-name: \SalesLoader
    template: templates.SalesLoader # shared with forum app
    ->
      super ...
      @children =
        sales: new SalesApp {} \body @
