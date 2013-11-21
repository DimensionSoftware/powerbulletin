define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  #pagedown # XXX pull in converter + sanitizer if needed on server
}
{templates} = require \../build/component-jade
{debounce}  = require \lodash
{lazy-load-fancybox} = require \../client/client-helpers

const max-retry = 3 # saving

module.exports =
  class Editor extends Component
    @dirty   = false
    @watcher = void
    @retry   = 0

    template: templates.Editor

    init: ->
      # defaults
      @local \id,   '' unless @local \id
      @local \body, '' unless @local \body

      # XXX why is this necessary?
      @dirty   = false
      @watcher = void
      @retry   = 0

    on-attach: ->
      ####  main  ;,.. ___  _
      # lazy-load-pagedown on client
      window.Markdown ||= {}
      <~ require <[pdEditor pdConverter pdSanitizer]>

      # init editor
      id      = @local \id
      html-id = if id then "\#wmd-input#id" else \#wmd-input
      editor  = @@$ html-id

      c = new Markdown.Converter!
      e = new Markdown.Editor c, id
      e.run!
      #{{{ - delegates
      # escape to close
      editor.on \keydown ~> if it.which is 27 then $.fancybox.close!; false
      editor.on \keyup   ~> @dirty=true # yo, editor--save me soon
      #}}}
      #{{{ - auto-save fns
      debounce = 2500ms # check dirty every...
      watch    = (fn) ~> @watcher = set-interval fn, debounce
      save-fn  = ~>
        if @dirty # save!
          clear-interval @watcher; @watcher=void # stop watching
          data = {}
          @@$.ajax {
            type : \PUT
            data : {config:sig:editor.val!}
            url  : @local \url
          }
            ..done (r) ~> # saved, so reset--
              @dirty=false
              @retry=0
              watch save-fn
            ..fail (r) ~> # failed, so try again until max-retries
              if ++@retry <= max-retry then watch save-fn
      # }}}
      watch save-fn # initial watch--go
      set-timeout (~> editor.focus!), 100ms # ... & focus!

    on-detach: -> # XXX ensure detach is called
      # cleanup
      @$.off!remove!
      clear-interval @watcher

# vim: fdm=marker
