require! {
  Component: yacomponent
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class PhotoCropper extends Component
    @pc = null

    #
    @start = (title="Profile Photo", aspect-ratio=1, endpoint-url="/resources/users/avatar", cb=(->)) ~>
      <~ lazy-load-fancybox
      unless @pc
        @pc = new PhotoCropper { aspect-ratio, endpoint-url, locals: { title, endpoint-url } }, $('<div/>')
        @pc.render!
      $.fancybox.open @pc.$, { after-load: cb }

    #
    ({title, aspect-ratio, @endpoint-url}) ->
      @aspect-ratio = parse-float aspect-ratio
      super ...

    #
    template: templates.PhotoCropper

    #
    init: ->
      if @aspect-ratio
        1 # stub
      else
        1 # stub

    #
    on-attach: ->
      1 # stub
