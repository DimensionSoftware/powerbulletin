require! \./Component.ls

module.exports =
  class HelloWorld extends Component
    template: ({name}={}) -> "<p>Hello, World</p>#{if name then ' <strong>' + name + '</strong>' else ''}"
    mutate: !($c, state) ->
      $strong = $c.find \strong
      $strong.text "#{$strong.text!}!" # add exclamation point in jquery (contrived I know)
    attach: ->
      @$top.on \click \strong -> alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
    detach: !->
      @$top.off!
