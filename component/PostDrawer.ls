define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor

{submit-form, post-success} = require \../client/client-helpers

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
        # XXX for now, always reply to active thread
        @$.find '[name="forum_id"]' .val active-forum-id
        @$.find '[name="parent_id"]' .val active-thread-id
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and sumbit!
          post-success ev, data

      make-resizable = ~>
        f = @@$ \footer
        unless f.data \uiResizable # guard
          f.resizable(
            handles: \n
            min-height: 100px
            max-height: 600px
            resize: (e, ui) ->
              # TODO respond resize
              window.save-ui!)

      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \ui-resizable-handle then return # guard
        console.log \toggle
        f = @@$ \footer
        if f.has-class \expanded or f.data \uiResizable # cleanup
          console.log \should-close
          @close!
        else # re-create?
          console.log \recreate
          unless @is-open
            console.log \yes
            make-resizable!

      # initially create
      make-resizable!

    is-open: ~> @@$ \footer .has-class \expanded
    close: ~>
      if @is-open
        console.log \closing
        f = @@$ \footer
        f
          ..css {top:'', height:''}
          ..remove-class \expanded
        try f.resizable \destroy

    on-detach: ->
      console.log \detach
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @close!
      @editor.detach!
      @editor = void
      try super ...
# vim:fdm=marker
