define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  lodash
  Component: yacomponent
  \./ParallaxButton
  \./Auth
  sh: \../shared/shared-helpers
  \../plv8_modules/pure-validations
}

{show-tooltip} = require \../client/client-helpers if window?
{each} = require \prelude-ls
{templates} = require \../build/component-jade

debounce = lodash.debounce _, 250ms

module.exports =
  class SiteRegister extends Component
    @last-subdomain = ''

    template: templates.SiteRegister
    init: ->
      # mandatory state
      @local \hostname, if env is \production then \.powerbulletin.com else \.pb.com
      @local \subdomain '' unless @local \subdomain

      # init children
      do ~>
        create-site = ~>
          subdomain = @local \subdomain
          @@$.post '/ajax/can-has-site-plz', {domain: subdomain+@local(\hostname)}, ({errors}:r) ~>
            if errors.length
              show-tooltip (@@$ \.SiteRegister-errors), errors.join \<br> if errors.length
            else
              window.location = "http://#subdomain#{@local \hostname}\#once"
        after-registration = ~>
          set-timeout create-site, 2000ms
        on-click = ~>
          @$.find \.SiteRegister-subdomain:first .focus!
          (Auth.require-registration create-site, after-registration)!
        locals = {title: \Start}
        @children =
          buy: new ParallaxButton {on-click, locals} \.SiteRegister-create @

    disable-ui: ~>
      @$.find \.SiteRegister-available
        ..remove-class 'success error'
        ..add-class \error
      @children.buy.disable!

    enable-ui: ~>
      @children.buy.enable!
      @$.find \.SiteRegister-available
        ..remove-class 'success error'
        ..add-class \success

    on-attach: ->
      $errors   = @@$ \.SiteRegister-errors
      component = @ # save

      @check-subdomain-availability = @@$R((subdomain) ~>
        if subdomain is @@last-subdomain
          return
        @@last-subdomain = subdomain
        errors = pure-validations.subdomain subdomain
        @@$.get \/ajax/check-domain-availability {domain: subdomain+@local(\hostname)} (res) ~>
          unless res.available then errors.push 'Domain is unavailable, try again!'
          children = [@parent.children.register-top, @parent.children.register-bottom]
          if errors.length
            each (.disable-ui!), children
            show-tooltip $errors, errors.join \<br> if errors.length
          else
            each (.enable-ui!), children
            show-tooltip $errors, ''
      ).bind-to @state.subdomain

      var last-val
      @$.on \click, \.hostname (ev) -> $ ev.target .prev \.SiteRegister-subdomain .focus!
      @$.on \keydown, \input.SiteRegister-subdomain, -> $ \.hostname .css \opacity, 0
      @$.on \keyup, \input.SiteRegister-subdomain, debounce ->
        new-input = $(@).val!
        if new-input.length
          $ \.hostname .animate {opacity:1, left:new-input.length * 27px + 32px}, 150ms # assume fixed-width font
          unless new-input is last-val
            # only signal changes on _different_ input
            component.state.subdomain new-input
          last-val := new-input
        else # disable if empty
          component.disable-ui!

    on-detach: ->
      sh.r-unbind @check-subdomain-availability
      delete @check-subdomain-availability
      @$.off \keyup \input.SiteRegister-subdomain

    update-subdomain: (s) ->
      @$.find('input.SiteRegister-subdomain').val s
