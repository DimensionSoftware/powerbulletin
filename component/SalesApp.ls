require! \./Component.ls
require! \./Sales.ls

{templates} = require \../build/component-jade.js

module.exports =
  class SalesApp extends Component
    template: templates.SalesApp
    init: ->
      @children =
        sales: new Sales {} \.SalesApp-content @
    on-attach: ->
      @@$ \.Sales-subdomain:first .focus!
