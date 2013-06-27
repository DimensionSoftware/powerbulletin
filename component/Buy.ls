require! Component: yacomponent

{templates} = require \../build/component-jade.js

module.exports =
  class Buy extends Component
    template: templates.Buy
    init: ->
      @local \cardNeeded, true if @local(\cardNeeded) is void
    on-attach: ->
      set-timeout (-> @@$ \.Buy-card-number .focus!), 100ms
      @$.on \click \.Buy-change-card ~>
        @local \cardNeeded, true
        @detach!render!attach!
        $fb = @@$ \.fancybox-wrap:first # animate switch
        $fb.remove-class \slide
        set-timeout (-> $fb.add-class \slide), 10ms
        false
      @$.on \click \.Buy-checkout (ev) ~>
        $ ev.target .attr \disabled \disabled # disable ui
        data =
          number:  @$.find \.Buy-card-number .val!
          expmo:   @$.find \.Buy-card-month .val!
          expyear: @$.find \.Buy-card-year .val!
          code:    @$.find \.Buy-card-code .val!
        show-tooltip (@$.find \.tooltip), 'Securing connection ...'
        @@$.post "/ajax/checkout/#{@local(\product).id}", data, (r) ~>
          if r.success
            $.fancybox.close!
            # TODO render new AdminUpgrade component

          else # error handling
            show-tooltip (@$.find \.tooltip), r.errors.join "\n" if r.errors?length
            card-number = @$.find \.Buy-card-number
            for e in [card-number, @@$ \.Buy-card-code] then e.add-class \error

            $fb = @@$ \.fancybox-wrap:first
            $fb.add-class \on-error
            $fb.remove-class \shake

            set-timeout (-> $fb.add-class \shake; card-number.focus!), 10ms
          $ ev.target .attr \disabled null # re-enable ui
        false
    on-detach: -> @$.off!
