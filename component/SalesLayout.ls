define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./Auth
require! Component: yacomponent
require! \./Sales
{templates} = require \../build/component-jade

module.exports =
  class SalesLayout extends Component
    template: templates.SalesLayout

    login: (user) ->
      # use user later
      @$.find 'li.auth a.onclick-login' .hide!
      @$.find 'li.auth a.onclick-logout' .show!

    logout: ->
      @$.find 'li.auth a.onclick-login' .show!
      @$.find 'li.auth a.onclick-logout' .hide!

