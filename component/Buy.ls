require! Component: yacomponent

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    init: ->
      @local \cardNeeded, true if @local(\cardNeeded) is void
    on-attach: ->
      @$.on \click \.Buy-change-card ~>
        @local \cardNeeded, true
        @detach!render!attach!
        return false
      @$.on \click \.Buy-checkout ~>
        data =
          number: @$.find(\.Buy-card-number).val!
          expiration: @$.find(\.Buy-card-expiration).val!
          code: @$.find(\.Buy-card-code).val!
        @@$.post "/ajax/checkout/#{@local(\product).id}", data, ->
          console.log ...arguments
        return false
    on-detach: -> @$.off!
