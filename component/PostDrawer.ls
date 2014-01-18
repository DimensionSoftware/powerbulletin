define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor

{submit-form, post-success} = require \../client/client-helpers

module.exports =
  class PostDrawer extends PBComponent

    editor: void

    init: !~>
      @footer = @@$ \footer

    on-attach: !~>
      #{{{ Event Delegates
      #}}}

      ####  main  ;,.. ___  _
      # + Editor
      @editor = new Editor {locals:{}}, \#editor, @
      @editor.render!attach!

      @$.find \.save .on \click (ev) ~>
        @$.find '[name="forum_id"]' .val active-forum-id
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and sumbit!
          post-success ev, data

      make-resizable = ~>
        unless @footer.data \uiResizable # guard
          @footer.resizable(
            handles: \n
            min-height: 100px
            max-height: 600px
            resize: (e, ui) ->
              # TODO respond resize
              window.save-ui!)

      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \ui-resizable-handle then return # guard
        if @footer.data \uiResizable # cleanup
          @footer.css {top:'', height:''}
          try @footer.resizable \destroy
        else # re-create?
          unless @footer .has-class \expanded
            make-resizable!

      # initially create
      make-resizable!

    on-detach: ->
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @editor.detach!
      @editor = void
      super ...

# vim:fdm=marker
