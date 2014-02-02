define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  #pagedown # XXX pull in converter + sanitizer if needed on server
}
{throttle} = require \lodash
{storage, lazy-load-fancybox} = require \../client/client-helpers

const watch-every   = 2500ms
const max-retry     = 3failures

module.exports =
  class Editor extends PBComponent
    retry:  0
    editor: void

    init: ->
      # defaults
      id = @local \id
      if id is true then id=''
      @local \id,        ''  unless id
      @local \body,      ''  unless @local \body
      @local \forumId,   ''  unless @local \forumId
      @local \parentId,  ''  unless @local \parentId
      @local \onClose, (->)  unless @local \onClose
      @local \key, (storage.get \user or window.user)?id unless @local \key

    # keys for local storage (must bind later, after the user exists)
    k-has-preview: ~> "#{@local \key}-editor-has-preview"
    k-tmp:         ~> "#{@local \key}-tmp"

    body: (v=void) ~>
      if v isnt void # save
        @local \body v
        @editor?val v
      @editor?val!

    clear: ~>
      @editor.val ''
      # clear preview, too
      id = @local \id
      html-id = if id then "\#wmd-preview#id" else \#wmd-preview
      $ html-id .html ''

    save: (to-server=false) ~>
      return unless @editor # guard
      k = @k-tmp! # local storage key
      v = @body!
      unless v is storage.get k
        storage.set k, v # update locally
        if to-server
          data = {}
          @@$.ajax {
            type : \PUT
            data : {editor:v}
            url  : @local \url
          }
            ..done (r) ~> # saved, so reset--
              @retry=0
            ..fail (r) ~> # failed, so try again (to server) until max-retries
              if ++@retry <= max-retry then @save true
    toggle-preview: ~>
      hidden = storage.get @k-has-preview!
      if hidden is null then hidden = true # default w/ preview
      storage.set @k-has-preview!, !hidden
      @$.toggle-class \has-preview, !hidden
      @focus!

    focus: -> set-timeout (~>
      e = @@$ 'footer [name="title"]:visible' # use title?
      if e?length then e.focus! else @editor?focus!), 50ms # ... & focus!

    on-attach: ~>
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
      @editor.on \keydown ~> if it.which is 27 then (@local \onClose)!; false # 27 is escape
      @editor.on \keyup, throttle @save, watch-every # save to local storage
      $ window .on \unload.Editor ~> @save true          # save to server
      #}}}
      @$.toggle-class \has-preview, (storage.get @k-has-preview!) or true # default w/ preview
      @focus!

    on-detach: ~> # XXX ensure detach is called
      # save to server & cleanup
      $ window .off \unload.Editor
      @save true
      @$.off!remove!

# vim: fdm=marker
