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
      c = new Markdown.Converter!
      e = new Markdown.Editor c, "-#{@local \id}"
      e.run!

      # TODO savehandle save

    on-detach: ->
      # TODO cleanup editors
      @$.off!
