require! Component: yacomponent
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

    login: (user) ->
      # use user later
      @$.find 'li.auth a.onclick-login' .hide!
      @$.find 'li.auth a.onclick-logout' .show!

    logout: ->
      @$.find 'li.auth a.onclick-login' .show!
      @$.find 'li.auth a.onclick-logout' .hide!

