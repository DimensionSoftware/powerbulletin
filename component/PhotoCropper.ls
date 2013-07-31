require! {
  Component: yacomponent
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class PhotoCropper extends Component
    ({aspect-ratio, @endpoint-url}) ->
      @aspect-ratio = parse-float aspect-ratio
      super ...
    template: templates.PhotoCropper
    init: ->
      if @aspect-ratio
        1 # stub
      else
        1 # stub
    on-attach: ->
      1 # stub
