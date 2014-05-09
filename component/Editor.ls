define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
}
{render}   = require \../shared/format
{throttle} = require \lodash
{storage, show-tooltip, lazy-load-fancybox} = require \../client/client-helpers

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
      @local \autoSave false unless @local \autoSave
      @local \key, (storage.get \user or window.user)?id unless @local \key

    # keys for local storage (must bind later, after the user exists)
    k-has-preview: ~> "#{@local \key}-editor-has-preview"
    k-tmp:         ~> "#{@local \key}-tmp"

    body: (v=void) ~>
      if v isnt void # save
        @local \body v
        @editor?val v
        @refresh-preview!
      @editor?val!

    clear: ~>
      @editor?val ''
      # clear preview, too
      $ preview-id-for(@local \id) .html ''

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
              show-tooltip (@$.find \.tooltip), 'Saved!', 3000ms
            ..fail (r) ~> # failed, so try again (to server) until max-retries
              if ++@retry <= max-retry then @save true

    refresh-preview: ~>
      $ preview-id-for(@local \id) .html render(@body!)
      @editor

    toggle-preview: ~>
      hidden = storage.get @k-has-preview!
      if hidden is null then hidden = true # default w/ preview
      storage.set @k-has-preview!, !hidden
      @$.toggle-class \has-preview, !hidden
      @refresh-preview!
      @focus!

    focus: -> set-timeout (~>
      e = @@$ 'footer [name="title"]:visible' # use title?
      if e?length and not e.val!length then e.focus! else @editor?focus!), 50ms # ... & focus!

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
      e.hooks.chain \onPreviewRefresh ~> @refresh-preview!
      e.run!
      @editor.pagedown = e # store
      #{{{ - delegates
      @$.find \.onclick-toggle-preview .on \click @toggle-preview
      @editor.on \keydown ~> if it.which is 27 then (@local \onClose)!; false # 27 is escape
      if @local \autoSave # bind save events:
        @editor.on \keyup, throttle @save, watch-every # to local storage
        $ window .on \unload.Editor ~> @save true      # to server
      #}}}
      @$.toggle-class \has-preview, (storage.get @k-has-preview!) or true # default w/ preview
      @focus!

    on-detach: ~> # XXX ensure detach is called
      if @local \autoSave # unbind save events
        $ window .off \unload.Editor
        @save true
      @$.off!remove! # cleanup

function preview-id-for id
  html-id = if id then "\#wmd-preview#id" else \#wmd-preview

# vim: fdm=marker
