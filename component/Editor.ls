define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
  #pagedown # XXX pull in converter + sanitizer if needed on server
}
{templates} = require \../build/component-jade
{lazy-load-fancybox} = require \../client/client-helpers

module.exports =
  class Editor extends Component
    template: templates.Editor

    init: ->
      # defaults
      @local \id,   '' unless @local \id
      @local \body, '' unless @local \body

    on-attach: ->
      # lazy-load-pagedown on client
      window.Markdown ||= {}
      <~ require <[pdEditor pdConverter pdSanitizer]>

      # init editor
      id      = @local \id
      html-id = if id then "\#wmd-input#id" else \#wmd-input

      c = new Markdown.Converter!
      e = new Markdown.Editor c, id
      e.run!
      set-timeout (~> @@$ html-id .focus!), 100ms # focus!

      # TODO handle save

    on-detach: ->
      # TODO cleanup editors
      @$.off!
