define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  #pagedown # XXX pull in converter + sanitizer if needed on server
}
{throttle}  = require \lodash
{templates} = require \../build/component-jade
{storage, lazy-load-fancybox} = require \../client/client-helpers

const watch-every   = 2500ms
const max-retry     = 3failures
const k-has-preview = \Editor.has-preview

module.exports =
  class Editor extends Component
    retry:  0
    editor: void

    template: templates.Editor

    init: ->
      # defaults
      @local \id,   '' unless @local \id
      @local \body, '' unless @local \body

    body: ~> @editor?val!
    save: (to-server=false) ~>
      return unless @editor # guard
      v = @editor.val!
      unless v is storage.get \sig
        storage.set \sig, v # update locally
        if to-server
          data = {}
          @@$.ajax {
            type : \PUT
            data : {config:sig:v}
            url  : @local \url
          }
            ..done (r) ~> # saved, so reset--
              @retry=0
            ..fail (r) ~> # failed, so try again (to server) until max-retries
              if ++@retry <= max-retry then @save true
    toggle-preview: ~>
      hidden = (storage.get k-has-preview) or false # default w/ preview
      storage.set k-has-preview, !hidden
      @$.toggle-class \has-preview, !hidden

    on-attach: ->
      ####  main  ;,.. ___  _
      # lazy-load-pagedown on client
      window.Markdown ||= {}
      <~ require <[pdEditor pdConverter pdSanitizer]>

      # init editor
      id      = @local \id
      html-id = if id then "\#wmd-input#id" else \#wmd-input
      @editor  = @@$ html-id

      c = new Markdown.Converter!
      e = new Markdown.Editor c, id
      e.run!
      #{{{ - delegates
      @$.find \.onclick-toggle-preview .on \click @toggle-preview
      @editor.on \keydown ~> if it.which is 27 then $.fancybox.close!; false # escape save & close
      @editor.on \keyup   throttle (~> @save), watch-every # save to local storage
      $ window .on \unload.Editor ~> @save true            # save to server
      #}}}
      @$.toggle-class \has-preview, (storage.get k-has-preview) or true # default w/ preview
      set-timeout (~> @editor.focus!), 100ms # ... & focus!

    on-detach: ~> # XXX ensure detach is called
      # save to server & cleanup
      $ window .off \unload.Editor
      @save true
      @$.off!remove!

# vim: fdm=marker
