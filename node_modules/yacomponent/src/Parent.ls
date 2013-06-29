require! \./Component
require! \./HelloWorld

module.exports =
  class Parent extends Component
    template: -> "<div class=\"Parent-hw\"></div>"
    init: ->
      @children =
        hw: new HelloWorld {}, \.Parent-hw, @
    on-attach: ->
      $(document).on \click @selector -> alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
    on-detach: !->
      $(document).off \click @selector
