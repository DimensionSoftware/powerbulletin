define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{show-tooltip} = require \../client/client-helpers

module.exports =
  class Buy extends PBComponent
    init: ->
      @local \cardNeeded, true if @local(\cardNeeded) is void
    on-attach: ->
      set-timeout (-> @@$ \.Buy-card-number .focus!), 350ms
      @$.on \click \.Buy-change-card ~>
        @local \cardNeeded, true
        @reload!
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
        product = @local \product .id
        re-enable = -> $ ev.target .attr \disabled null
        show-tooltip (@$.find \.tooltip), 'Securing connection', 30000ms
        @@$.post "/ajax/checkout/#product", data, (r) ~>
          if r.success
            site.subscriptions.push product # subscribe!
            site.has_stripe = true
            $ "\##product" .focus!
            show-tooltip (@$.find \.tooltip), (['Sincere thanks!', "Awesome.  Go ahead!", 'You got it!', 'Thank you!'][parse-int Math.random!*5])
            set-timeout (->
              re-enable!
              # show new product
              $ ".#{product}-available" .hide!
              $ ".#{product}-purchased" .show 500ms
              $.fancybox.close!), 2000ms

          else # error handling
            show-tooltip (@$.find \.tooltip), if r.errors?length then r.errors.join "\n" else 'Invalid payment!'
            card-number = @$.find \.Buy-card-number
            for e in [card-number, @@$ \.Buy-card-code] then e.add-class \has-error

            $fb = @@$ \.fancybox-wrap:first
            $fb.add-class \on-error
            $fb.remove-class \shake

            set-timeout (-> $fb.add-class \shake; card-number.focus!), 10ms
            re-enable!
        false
    on-detach: -> @$.off!
