require! \./Component

module.exports =
  class HelloWorld extends Component
    template: ({name}={}) ->
      "<p>Hello, World</p>#{if name then ' <strong>' + name + '</strong>' else ''}"
    mutate: !($dom) ->
      $strong = $dom.find \strong
      $strong.text "#{$strong.text!}!" # add exclamation point in jquery (contrived I know)
    on-attach: ->
      @$.on \click \p ->
        alert 'say my name say my name, you acting kinda shady aint callin me baby why the sudden change?'
    on-detach: ->
      @$.off \click \p
