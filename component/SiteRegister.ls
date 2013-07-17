require! {
  lodash
  Component: yacomponent
  \./ParallaxButton.ls
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

debounce = lodash.debounce _, 250

module.exports =
  class SiteRegister extends Component
    hostname = if process.env.NODE_ENV is \production then \.powerbulletin.com else \.pb.com
    template: templates.SiteRegister
    init: ->
      # mandatory state
      @local \hostname, hostname
      @local \subdomain '' unless @local \subdomain

      # init children
      do ~>
        on-click = ~>
          console.log \created: + subdomain
          subdomain   = @local \subdomain
          @@$.post '/ajax/can-has-site-plz', {domain: subdomain+hostname}, ({errors, transient_owner}:r) ->
            if errors.length
              console.error errors
            else
              cookie-opts =
                domain: hostname
                expires: 1

              # set cookie so they are 'admin' of temporary site
              if r.user_id
                window.location = "http://#subdomain#hostname\#once"
              else
                $.cookie \transient_owner, transient_owner, cookie-opts
                window.location = "http://#subdomain#hostname"
        locals = {title: 'Create Community'}
        @children =
          buy: new ParallaxButton {on-click, locals} \.SiteRegister-create @

    on-attach: ->
      component = @
      $sa = @$.find(\.SiteRegister-available)

      @check-subdomain-availability = @@$R((subdomain) ->
        @@$.get \/ajax/check-domain-availability {domain: subdomain+hostname} (res) ->
          $sa.remove-class 'success error'
          if res.available
            component.children.buy.enable!
            $sa.add-class \success
          else
            component.children.buy.disable!
            $sa.add-class \error
      ).bind-to @state.subdomain

      var last-val
      @$.on \keyup, \input.SiteRegister-subdomain, debounce ->
        new-input = $(@).val!

        console.log \xxx, new-input, last-val
        unless new-input is last-val
          # only signal changes on _different_ input
          component.state.subdomain new-input

        last-val := new-input

    on-detach: ->
      sh.r-unbind @check-subdomain-availability
      delete @check-subdomain-availability
      @$.off \keyup \input.SiteRegister-subdomain

    update-subdomain: (s) ->
      @$.find('input.SiteRegister-subdomain').val s
