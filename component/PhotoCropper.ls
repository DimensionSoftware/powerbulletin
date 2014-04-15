define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  sh: \../shared/shared-helpers
}
{lazy-load-fancybox, lazy-load-jcrop} = require \../client/client-helpers

module.exports =
  class PhotoCropper extends PBComponent
    # only one photocropper on screen at a time
    @pc = null

    # helper function to put photocropper in a fancybox
    @start = ({title="Profile Photo", photo, aspect-ratio=1/1, endpoint-url=null}={}, cb=(->)) ~>
      unless photo
        photo = if user.photo
          p = user.photo.replace \avatar., \avatar-to-crop.
          p.replace /\?[\w]+$/, '' # query string
        else
          \/images/profile.png
      endpoint-url = "/resources/users/#{user.id}/avatar" unless endpoint-url

      <~ lazy-load-fancybox
      @pc = new PhotoCropper { aspect-ratio, endpoint-url, locals: { title, photo, endpoint-url } }
      @pc.crop-mode {url:photo}
      $.fancybox.open @pc.$, { after-load: cb }

    #
    ({title, aspect-ratio, @endpoint-url}) ->
      @aspect-ratio = parse-float aspect-ratio
      super ...

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
      @$.find \img:first .on \load ~> # render correctly-sized cropper
        @$.find \.crop .show!
        @@$.fancybox.update!
        @$.find \h1 .hide!
        <~ set-timeout _, 300ms
        @$.find \.crop .add-class \show

      @$.find('.upload input[type=file]').html5-uploader { # upload
        name: \avatar
        post-url: @endpoint-url
        on-success: (xhr, file, r-json) ~>
          r = JSON.parse(r-json)
          cache-buster = Math.random!to-string!replace \\. ''
          @$.find \img .attr \src, "#{cacheUrl}#{r.url}?#cache-buster"
          @crop-mode r
      }

      @$.find \.onclick-save .click @crop

    #
    upload: ->
      data = @$.find('form').serialize!
      jqxhr = @@$.post @endpoint-url, data
      jqxhr.done (r) ~>
        @crop-mode r
      jqxhr.fail (r) ~>
        console.warn 'upload failed', r

    bounds: []
    update-preview: (coords) ~>
      if w = parse-int coords.w
        [boundx, boundy] = if @bounds.length then @bounds else [0, 0]
        rx = 150 / coords.w
        ry = 150 / coords.h
        $ \#preview .css {
          width:  "#{Math.round(rx * boundx)}px",
          height: "#{Math.round(ry * boundy)}px",
          margin-left: "-#{Math.round(rx * coords.x)}px",
          margin-top:  "-#{Math.round(ry * coords.y)}px",
        }

    # this is the mode for cropping an uploaded image
    crop-mode: (r) ->
      if r
        @$.data \path, r.url
      <~ lazy-load-jcrop
      @jcrop.destroy! if @jcrop
      options =
        aspect-ratio: @aspect-ratio
        on-change: @update-preview
        on-select: @update-preview
      options <<< @box-dimensions!
      fb = @@$.fancybox
      save-jcrop = (j) ~> @jcrop = j
      component  = @
      @$.find '.crop img:first' .Jcrop options, ->
        save-jcrop this
        fb.update!
        component.bounds = @get-bounds!

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
      data.path = data.path.replace \-to-crop, ''
      jqxhr = @@$.ajax {
        type : \PUT
        data : data
        url  : @endpoint-url
      }
      jqxhr.done (r) ~>
        @@$.fancybox.close!
      jqxhr.fail (r) ~>
        console.warn 'upload failed', r
