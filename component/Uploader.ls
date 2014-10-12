define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

{show-tooltip, lazy-load-html5-uploader} = require \../client/client-helpers

# XXX this component must be rendered inside a <form enctype="multipart/form-data">

module.exports =
  class Uploader extends PBComponent
    default-locals =
      post-url:   ''
      on-success: (->)

    init: !->
      @local \name, \background unless @local \name
      for k,v of default-locals when @local(k) is void
        @local k, v

    delete-preview: ->
      @@$.ajax {method:\DELETE, url:(@local \postUrl), data: {src:@local \preview} }
        ..error (data) ~>
          show-tooltip (@@$ \#warning), if typeof! data.msg?0 is \String then data.msg.0 else 'Unable to Delete!'
        ..success (data) ~>
          @set-preview void # remove thumb
          @$.remove-class \has-attachment
          if cb = @locals!on-delete
            cb data

    reset: -> # reset ui
      @$.find \.inline-text .hide!
      @$.find \.inline-preview
        ..data \src, void
        ..attr \src, "#{cacheUrl}/images/transparent-1px.gif"
        ..show!
      @$.find \.progress
        ..css \width, 0px
      @$.remove-class \has-attachment

    set-preview: (uri) ->
      if uri?match /\.(jpg|gif|bmp|png)\??/i
        # show preview
        @$.find \.inline-text .hide!
        @$.find \.inline-preview
          ..data \src, uri
          ..attr \src,
            if uri and not uri.match /transparent-1px/
              "#{cacheUrl}/sites/#uri"
            else
              "#{cacheUrl}/images/transparent-1px.gif"
          ..show!
      else
        if uri # show filename
          uri = uri.replace /^.+\//, '' # remove leading site-id
          file-name = (uri?match /(.+)?\./ .1) or ''
          file-ext  = (uri?match /\.([\w\d]{1,4})\??/ .1) or ''
          @$.find \.inline-preview
            ..attr \src, '' # show delete button
            ..hide!
          @$.find \.inline-text
            ..html "#{file-name or \Attachment}.<small>#file-ext</small>"
            ..show!
        else
          @reset!

    upload: -> # fire upload event
      # FIXME don't use-- isn't cross-browser
      # - can work around security exception in some browsers by creating mouse events
      @$.find "label[for='#{@local \name}']" .trigger \click

    on-attach: !->
      <~ lazy-load-html5-uploader

      #{{{ Event Delegates
      @$.on \click \.onclick-delete (ev) ~> # delete
        ev.prevent-default!
        if confirm "Permanently Delete?"
          @delete-preview!
        false
      #}}}

      init-html5-uploader = (locals) ~>
        @set-preview locals.preview
        @$.find('.drop-target, input[type=file]').html5-uploader {
          name: locals.name
          post-url: locals.postUrl
          on-server-progress: (progress, file) ~>
            @$.add-class \has-attachment
            if @local \hideBrowse then @$.find \.button .remove-class \hidden
            @$.find \.action .css \visibility, \hidden
            p = parse-int((progress.loaded/file.size) * 100)
            @$.find \.progress # progress update!
              ..html p + '<small>%</small>'
              ..css  \width, (if p < 35 then 35 else p) + \%
          on-client-load-end: ~> # XXX does this work?  added code to on-success just in case
            @$.find \.progress .width 0px
            @$.find \.action .css \visibility, \visible
            if @local \hideBrowse then @$.find \.button .add-class \hidden
          on-success: (xhr, file, r-json) ~>
            if @local \hideBrowse then @$.find \.button .add-class \hidden
            @$.find \.progress .width 0px
            @$.find \.action
              ..html \Browse
              ..css \visibility, \visible
            # load current preview
            try r = JSON.parse r-json
            if r?success
              @set-preview r[locals.name]
              @local \preview, r[locals.name]
            else
              show-tooltip ($ \.tooltip:first), r?msg or 'Try Again!'
            if locals.on-success then locals.on-success xhr, file, try JSON.parse r-json
          on-failure: (xhr, file, r-json) ~>
            if @local \hideBrowse then @$.find \.button .add-class \hidden
            try r = JSON.parse r-json
            show-tooltip ($ \.tooltip:first), r?msg
            @$.find \.progress
              ..css \width, 0px
            @$.find \.action
              ..html 'Try Again'
              ..css \visibility, \visible
            @$.remove-class \has-attachment
        }

      ####  main  ;,.. ___  _
      init-html5-uploader @locals!

    on-detach: -> @$.off!; @$.html '' # cleanup & reap

# vim:fdm=marker
