define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./Auth
require! Component: yacomponent
require! \./Sales
require! \./MiniSiteList
require! ch: \../client/client-helpers
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

      @@$ \.onclick-my-sites .click @show-my-sites

    login: (user) ->
      # use user later
      @$.find 'li.auth a.onclick-login' .hide!
      @$.find 'li.auth a.onclick-logout' .show!
      @$.find 'li.my-sites' .show!
      @$.find 'li.community' .hide!
      set-timeout (~> @show-my-sites!), 800ms

    logout: ->
      @$.find 'li.auth a.onclick-login' .show!
      @$.find 'li.auth a.onclick-logout' .hide!
      @$.find 'li.community' .show!
      @$.find 'li.my-sites' .hide!

    show-my-sites: ~>
      return if $('#auth:visible .register').length #guard
      <~ ch.lazy-load-fancybox
      $div = $ '<div/>'
      r <~ @@$.get '/ajax/sites-and-memberships'
      if r.success
        msl = new MiniSiteList({locals: r}, $div)
        $.fancybox.open $div
      else
        # error
