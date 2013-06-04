require! {
  lodash
  \./Component.ls
  \./ParallaxButton.ls
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

debounce = lodash.debounce _, 250

module.exports =
  class Sales extends Component
    component-name: \Sales
    template: templates.Sales
    ->
      super ...
      # mandatory state
      @state.domain ||= @@$R.state ''

      # init children
      do ~>
        on-click = ->
          console.log \create-community
        locals = {title: 'Create my community'}
        @children =
          buy: new ParallaxButton {on-click, locals} \.Sales-create @
    on-attach: ->
      @check-domain-availability = @@$R((domain) ->
        $.get \/ajax/check-domain-availability {domain} (res) ->
          console.log res
      ).bind-to @state.domain

      component = @

      @$.on \keyup, \input.Sales-domain, debounce ->
        new-input = $(@).val!
        unless new-input is component.local(\domain)
          # only signal changes on _different_ input
          component.state.domain new-input
    on-detach: ->
      sh.r-unbind @check-domain-availability
      delete @check-domain-availability
      @$.off \keyup \input.Sales-domain
