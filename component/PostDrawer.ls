define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor
require! furl: \../shared/forum-urls

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
        @$.find '[name="parent_id"]' .val(if @is-creating-thread! then void else window.active-thread-id)
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and sumbit!
          post-success ev, data
          if @is-editing # update ui
            if p = data.post?0
              e = $ "[data-post-id='#{p.id}']"
              if e.length # in DOM?
                e.find \.title .html p.title
                e.find \.body  .html p.body
                @edit-mode! # back to default Reply mode
      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \onclick-footer-toggle # guard
          if in-thread-mode! # keep drawer open & clear inputs
            thread-mode false # replies don't have titles
            @editor
              ..clear!
              ..focus!
          else
            f = @footer!
            if f.has-class \expanded and f.data \uiResizable # cleanup & close
              @close!
            else # re-create?
              make-resizable f
        false
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
      make-resizable f
      # setup Editor
      <~ set-timeout _, 50ms
      unless @is-creating-thread! or @is-editing! then thread-mode false # remove title
      @focus!
    close: ~>
      set-timeout (~>
        if @is-open!
          f = @footer!
            ..css {top:'', height:''}
            ..remove-class \expanded
          try f.resizable \destroy
          f.data \uiResizable, void), 50ms

    focus: ~> @editor.focus!
    clear: ~> # clear all inputs
      @editor.clear!
      @@$ '[name="title"]'     .val ''
      @@$ '[name="forum_id"]'  .val ''
      @@$ '[name="parent_id"]' .val ''
      @@$ '[name="id"]'        .val ''
      @edit-mode! # back to reply mode
    is-creating-thread: ~> (furl.parse window.location.pathname)?type is \new-thread
    is-editing: ~> (@@$ \.form:first .attr \method) is \put
    edit-mode: (id) ~>
      $f = @@$ \.form:first # setup mock form for:
      if id # edit mode
        $f.attr \method, \put
        $f.attr \action, "/resources/posts/#{id}"
        \edit
      else # reply mode
        $f.attr \method, \post
        $f.attr \action, \/resources/posts
        \reply

    set-post: (p) ~>
      @editor.clear! # reset preview, etc...
      # FIXME set post using accessor
      @@$ '[name="body"]' .val p.body
      $f = @@$ \.form:first # setup mock form for:
      @edit-mode p.id
      if p.title # top-level post; so--bring out title
        thread-mode!
        @@$ '[name="title"]'     .val p.title

      @@$ '[name="forum_id"]'  .val p.forum_id
      @@$ '[name="parent_id"]' .val p.parent_id
      @@$ '[name="id"]'        .val p.id

      @editor.editor?pagedown?refresh-preview!

    on-detach: ->
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @$.off!
      @close!
      @editor.detach!
      @editor = void
      try super ...


function make-resizable e
  unless e.data \uiResizable # guard
    e.add-class \expanded
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
