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
    @start = ({title="Profile Photo", mode=\upload, photo=null, aspect-ratio=1/1, endpoint-url=null}={}, cb=(->)) ~>
      photo        = user.photo                           unless photo
      endpoint-url = "/resources/users/#{user.id}/avatar" unless endpoint-url

      <~ lazy-load-fancybox
      @pc = new PhotoCropper { aspect-ratio, endpoint-url, locals: { title, photo, endpoint-url } }
      if mode is \crop
        @pc.crop-mode { url: photo }
      $.fancybox.open @pc.$, { after-load: cb }

    #
    ({title, aspect-ratio, @endpoint-url}) ->
      @aspect-ratio = parse-float aspect-ratio
      super ...

    #
    template: templates.PhotoCropper

    # jcrop object
    jcrop: null

    #
    init: ->
      if @aspect-ratio
        1 # stub
      else
        1 # stub

    #
    on-attach: ->

      #@$.find('.upload input[type=file]').change ~>
      #  @upload!

      @$.find('.upload input[type=file]').html5-uploader {
        name: \avatar
        post-url: @endpoint-url
        on-success: (xhr, file, r-json) ~>
          r = JSON.parse(r-json)
          cache-buster = Math.random!to-string!replace \\. ''
          @$.find \img .attr \src, "#{cacheUrl}#{r.url}?#cache-buster"
          @crop-mode r
      }

      @$.find('.crop .button').click @crop

    #
    upload: ->
      data = @$.find('form').serialize!
      jqxhr = @@$.post @endpoint-url, data
      jqxhr.done (r) ~>
        @crop-mode r
      jqxhr.fail (r) ~>
        console.warn 'upload failed', r

    # this is the default mode where new images can be uploaded
    upload-mode: ->
      @$.find \.crop .hide!
      @$.find \.upload .show!

    # this is the mode for cropping an uploaded image
    crop-mode: (r) ->
      if r
        @$.data \path, r.url
      @$.find \.upload .hide!
      @$.find \.crop .show!
      <~ lazy-load-jcrop
      @jcrop.destroy! if @jcrop
      options =
        aspect-ratio: @aspect-ratio
      options <<< @box-dimensions!
      fb = @@$.fancybox
      save-jcrop = (j) ~> @jcrop = j
      @$.find '.crop img' .Jcrop options, ->
        save-jcrop this
        fb.update!

    # constrain image size in case we have to crop an image bigger than the window
    box-dimensions: ->
      fancybox-side-margin = 35
      resize = 0.95
      {
        box-width  : parse-int( @@$(window).width!  - (fancybox-side-margin * 2) )
        box-height : parse-int( @@$(window).height! * resize )
      }

    #
    crop: (ev) ~>
      data = @jcrop.tell-select!
      data.path = @$.data \path
      if data.height is 0 or data.width is 0
        # TODO - warn that a crop selection has not been made
        return
      jqxhr = @@$.ajax {
        type : \PUT
        data : data
        url  : @endpoint-url
      }
      jqxhr.done (r) ~>
        @@$.fancybox.close!
      jqxhr.fail (r) ~>
        console.warn 'upload failed', r
