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

      @$.find \.save .on \click (ev) ~>
        @$.find '[name="forum_id"]' .val active-forum-id
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and sumbit!
          post-success ev, data

      f = @@$ \footer
      create-resizable = ~>
        unless f.data \uiResizable
          f.resizable(
            handles: \n
            min-height: 100px
            max-height: 600px
            resize: (e, ui) ->
              # TODO respond resize
              window.save-ui!)

      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \ui-resizable-handle then return # guard
        if f.data \uiResizable # cleanup
          f.css {top:'', height:''}
          try f.resizable \destroy
        else # re-create
          create-resizable!

      # initially create
      create-resizable!

    on-detach: ->
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @editor.detach!
      @editor = void
      super ...

# vim:fdm=marker
