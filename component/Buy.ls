require! Component: yacomponent

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    init: ->
      @local \cardNeeded, true if @local(\cardNeeded) is void
    on-attach: ->
      set-timeout (-> @@$ \.Buy-card-number .focus!), 200ms
      @$.on \click \.Buy-change-card ~>
        @local \cardNeeded, true
        @detach!render!attach!
        return false
      @$.on \click \.Buy-checkout ~>
        data =
          number:  @$.find \.Buy-card-number .val!
          expmo:   @$.find \.Buy-card-month .val!
          expyear: @$.find \.Buy-card-year .val!
          code:    @$.find \.Buy-card-code .val!
        @@$.post "/ajax/checkout/#{@local(\product).id}", data, ->
          console.log ...arguments
        return false
    on-detach: -> @$.off!
