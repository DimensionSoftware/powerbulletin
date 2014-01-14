define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

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

    on-detach: ->
      @editor.detach!
      @editor = void
      super ...

# vim:fdm=marker
