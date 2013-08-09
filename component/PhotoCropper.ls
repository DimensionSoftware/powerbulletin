require! {
  Component: yacomponent
  sh: \../app/shared-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class PhotoCropper extends Component
    # only one photocropper on screen at a time
    @pc = null

    # helper function to put photocropper in a fancybox
    @start = ({title="Profile Photo", photo=null, aspect-ratio=1, endpoint-url=null}, cb=(->)) ~>
      photo        = user.photo                           unless photo
      endpoint-url = "/resources/users/#{user.id}/avatar" unless endpoint-url

      <~ lazy-load-fancybox
      @pc = new PhotoCropper { aspect-ratio, endpoint-url, locals: { title, photo, endpoint-url } }
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
      @$.find('.upload .button').click ~>
        @$.find('.upload input[type=file]').click!

      @$.find('.upload input[type=file]').change ~>
        @crop-mode!
      1 # stub

    # this is the default mode where new images can be uploaded
    upload-mode: ->
      @$.find \.crop .hide!
      @$.find \.upload .show!

    # this is the mode for cropping an uploaded image
    crop-mode: ->
      @$.find \.upload .hide!
      @$.find \.crop .show!

