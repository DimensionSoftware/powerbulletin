define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor

module.exports =
  class PostDrawer extends PBComponent

    editor: void

    init: !~>

    on-attach: !~>
      #{{{ Event Delegates
      #}}}

      ####  main  ;,.. ___  _
      # + Editor
      @editor = new Editor {locals:{}}, \#editor, @
      @editor.render!attach!

      @.$.resizable(
        min-height: 100px
        max-height: 600px
        resize: (e, ui) ->
          # TODO respond resize
          console.log \resize
          window.save-ui!)

    on-detach: ->
      @editor.detach!
      @editor = void
      super ...

# vim:fdm=marker
