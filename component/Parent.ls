require! \./Component.ls
require! \./HelloWorld.ls

module.exports =
  class Parent extends Component
    component-name: \Parent
    template: -> "<div class=\"Parent-hw\"></div>"
    children: ->
      * new HelloWorld {} @$.find(\.Parent-hw)
    on-attach: ->
      $(document).on \click @selector -> alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
    on-detach: !->
      $(document).off \click @selector
