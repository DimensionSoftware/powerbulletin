define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  lodash
  \./PBComponent
  \./ParallaxButton
  \./Auth
  sh: \../shared/shared-helpers
  \../plv8_modules/pure-validations
}

{show-tooltip} = require \../client/client-helpers if window?
{each} = require \prelude-ls

debounce = lodash.debounce _, 850ms

module.exports =
  class SiteRegister extends PBComponent
    @last-subdomain = ''

    init: ->
      # mandatory state
      @local \hostname, if env is \production then \.powerbulletin.com else \.pb.com
      @local \subdomain '' unless @local \subdomain

      # init children
      do ~>
        create-site = ~>
          return if (@local \subdomain)?match /^\s*$/ # guard
          children = [@parent.children.register-top, @parent.children.register-bottom]
          each (.disable-ui!), children
          show-tooltip (@@$ \.SiteRegister-errors), 'Reserving Your Address'
          subdomain = @local \subdomain
          @@$.post '/ajax/can-has-site-plz', {domain: subdomain+@local(\hostname)}, ({errors}:r) ~>
            each (.enable-ui!), children
            if errors?length
              show-tooltip (@@$ \.SiteRegister-errors), errors.join \<br> if errors?length
            else
              window.location = "https://#subdomain#{@local \hostname}\#once"
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
          unless res.available then errors.push 'Domain is Unavailable, Try Again!'
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
      @$.on \keyup, \input.SiteRegister-subdomain, debounce (ev) ~>
        new-input = $ ev.target .val!
        if new-input.length
          w = (@$.find \.hostname-hidden .html new-input).width! # px width of input
          $ \.hostname .transition {opacity:1, left:w}, 300ms, \easeOutExpo
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
