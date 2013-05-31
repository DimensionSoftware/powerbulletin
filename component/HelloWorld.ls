require! \./Component.ls

module.exports =
  class HelloWorld extends Component
    template: ({name}={}) ->
      "<div class=\"HelloWorld\"><p>Hello, World</p>#{if name then ' <strong>' + name + '</strong>' else ''}</div>"
    mutate: !($c, state) ->
      $strong = $c.find \strong
      $strong.text "#{$strong.text!}!" # add exclamation point in jquery (contrived I know)
    on-attach: ->
      $(document).on \click @selector -> alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
    on-detach: !->
      $(document).off \click @selector
