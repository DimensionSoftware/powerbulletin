define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor

{in-thread-mode, thread-mode, storage, submit-form, post-success} = require \../client/client-helpers

module.exports =
  class PostDrawer extends PBComponent

    editor: void
    footer: ~> @@$ \footer

    on-attach: !~>
      #{{{ Event Delegates
      @$.find \.save .on \click (ev) ~>
        # XXX for now, always reply to active thread
        @$.find '[name="forum_id"]' .val window.active-forum-id
        @$.find '[name="parent_id"]' .val window.active-thread-id
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and sumbit!
          post-success ev, data

      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \onclick-footer-toggle # guard
          if in-thread-mode! # keep drawer open & clear inputs
            thread-mode false # replies don't have titles
            @editor.clear!
          else
            f = @footer!
            if f.has-class \expanded or f.data \uiResizable # cleanup & close
              @close!
            else # re-create?
              unless @is-open
                make-resizable f
      #}}}
      ####  main  ;,.. ___  _
      # + Editor
      @editor = new Editor {locals:{id:active-thread-id?}}, \#editor, @
      @editor.render!attach!

    toggle:  ~> if @is-open! then @close! else @open!
    is-open: ~> @footer!has-class \expanded
    open: ~>
      p = window.get-prefs!
      if p then [_, _, h?] = p
      f = @footer!
        ..height h? or \200 # default
        ..add-class \expanded
      # TODO trigger resize or use CSS?
      make-resizable f
      # setup Editor
      <~ set-timeout _, 50ms
      @editor.focus!
    close: ~>
      set-timeout (~>
        if @is-open!
          f = @footer!
            ..css {top:'', height:''}
            ..remove-class \expanded
          try f.resizable \destroy), 50ms

    set-post: (p) ~>
      @@$ '[name="body"]' .val p.body
      if p.title # top-level post; so--bring out title
        thread-mode!
        @@$ '[name="title"]'     .val p.title
        @@$ '[name="forum_id"]'  .val p.forum_id
        @@$ '[name="parent_id"]' .val p.parent_id
        @@$ '[name="id"]'        .val p.id

    on-detach: ->
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @$.off!
      @close!
      @editor.detach!
      @editor = void
      try super ...


function make-resizable e
  unless e.data \uiResizable # guard
    e.resizable(
      handles: \n
      min-height: 100px
      max-height: 600px
      resize: (el, ui) ->
        h = ui.size.height - 40px
        #e # respond resize (TODO use css)
        #  ..find \.wmd-panel .height h
        #  ..find \.wmd-preview .height h
        window.save-ui!)

# vim:fdm=marker
