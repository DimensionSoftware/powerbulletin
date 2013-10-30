define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}

{templates} = require \../build/component-jade

# XXX this component must be rendered inside a <form enctype="multipart/form-data">

module.exports =
  class Uploader extends Component
    default-locals =
      post-url:   ''
      on-success: (->)

    template: templates.Uploader

    init: !->
      for k,v of default-locals when @local(k) is void
        @local k, v

    set-background-thumb: (uri) ->
      @$.find \.background
        ..data \src, uri
        ..attr \src,
          if uri
            "#{cacheUrl}/sites/#uri"
          else
            "#{cacheUrl}/images/transparent-1px.gif"


    on-attach: !->
      #{{{ Event Delegates
        # TODO delete
      #}}}

      init-html5-uploader = (locals) ~>
        @set-background-thumb locals.background
        @$.find('.drop-target, input.upload[type=file]').html5-uploader {
          name: \background
          post-url: locals.postUrl
          on-success: (xhr, file, r-json) ~>
            # load current background
            r = JSON.parse r-json
            if r.success
              @set-background-thumb r.background
              locals.onSuccess xhr, file, r-json}

      ####  main  ;,.. ___  _
      init-html5-uploader @locals!

    on-detach: -> @$.off!; @$.html '' # cleanup & reap

# vim:fdm=marker
