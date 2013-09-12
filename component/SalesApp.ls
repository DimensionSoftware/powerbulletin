define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./Auth
require! Component: yacomponent
require! \./Sales
{templates} = require \../build/component-jade

module.exports =
  class SalesApp extends Component
    template: templates.SalesApp

    init: ->
      @local \cacheUrl, null # define early, since it is passed to child

      s = @state
      @children =
        sales: new Sales {locals: {s.cache-url}} \.SalesApp-content @

    on-attach: ->
      @@$ \.Sales-subdomain:first .focus!

    login: (user) ->
      # use user later
      @$.find 'li.auth a.onclick-login' .hide!
      @$.find 'li.auth a.onclick-logout' .show!

    logout: ->
      @$.find 'li.auth a.onclick-login' .show!
      @$.find 'li.auth a.onclick-logout' .hide!

