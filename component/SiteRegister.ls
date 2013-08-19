define = window?define or require(\amdefine) module

define (require, exports, module) ->
  require! {
    lodash
    Component: yacomponent
    \./ParallaxButton
    \./Auth
    sh: \../shared/shared-helpers
    ch: \../client/client-helpers
    \../plv8_modules/pure-validations
  }
  {templates} = require \../build/component-jade

  debounce = lodash.debounce _, 250ms

  module.exports =
    class SiteRegister extends Component
      template: templates.SiteRegister
      init: ->
        # mandatory state
        @local \hostname, if global.env is \production then \.powerbulletin.com else \.pb.com
        @local \subdomain '' unless @local \subdomain

        # init children
        do ~>
          on-click = Auth.require-registration ~>
            subdomain = @local \subdomain
            @@$.post '/ajax/can-has-site-plz', {domain: subdomain+@local(\hostname)}, ({errors}:r) ~>
              if errors.length
                ch.show-tooltip (@@$ \.SiteRegister-errors), errors.join \<br> if errors.length
              else
                window.location = "http://#subdomain#{@local \hostname}\#once"
          locals = {title: \Create}
          @children =
            buy: new ParallaxButton {on-click, locals} \.SiteRegister-create @

      on-attach: ->
        component = @
        $sa = @$.find \.SiteRegister-available
        $errors = @@$ \.SiteRegister-errors

        @check-subdomain-availability = @@$R((subdomain) ~>
          errors = pure-validations.subdomain subdomain
          @@$.get \/ajax/check-domain-availability {domain: subdomain+@local(\hostname)} (res) ->
            $sa.remove-class 'success error'
            if res.available
              component.children.buy.enable!
              $sa.add-class \success
            else
              component.children.buy.disable!
              $sa.add-class \error
              errors.push 'Domain is unavailable, try again!'

            ch.show-tooltip $errors, errors.join \<br> if errors.length
        ).bind-to @state.subdomain

        var last-val
        @$.on \keydown, \input.SiteRegister-subdomain, -> $ \.hostname .css \opacity, 0
        @$.on \keyup, \input.SiteRegister-subdomain, debounce ->
          new-input = $(@).val!
          if new-input.length
            $ \.hostname .animate {opacity:1, left:new-input.length * 27px + 32px}, 150ms # assume fixed-width font
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
