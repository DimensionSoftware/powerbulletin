define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor
require! furl: \../shared/forum-urls

{in-thread-mode, thread-mode, storage, submit-form, post-success} = require \../client/client-helpers
{is-forum-homepage} = require \../shared/shared-helpers

module.exports =
  class PostDrawer extends PBComponent

    editor: void
    footer: ~> @@$ \footer

    on-attach: !~>
      #{{{ Event Delegates
      @$.find \.save .on \click (ev) ~>
        # XXX for now, always reply to active or nearest in DOM (context) thread
        @$.find '[name="forum_id"]' .val(window.active-forum-id or @context-forum-id)
        @$.find '[name="parent_id"]' .val(
          if @is-creating-thread! then void else (window.active-thread-id or @context-thread-id))
        ev = {target:@editor.$} # mock event
        submit-form ev, (data) ~> # ...and submit!
          post-success ev, data
          if @is-editing # update ui
            @edit-mode! # back to default Reply mode
          else # for reply mode only
            @delete-draft!
      @@$ \.onclick-footer-toggle .on \click.post-drawer (ev) ~>
        if $ ev.target .has-class \onclick-footer-toggle # guard
          @context-forum-id = ($ ev.target .parents '[data-forum-id]').data \forum-id
          if in-thread-mode!
            if @is-editing! # if editing, hold drawer open & switch modes
              thread-mode false # replies don't have titles
              @edit-mode! # back to default Reply mode
              @editor
                ..clear!
                ..focus!
            else # user indicated close
              @close!
          else # user indicated toggle
            @clear! # back to Reply mode
            thread-mode false
            f = @footer!
            if f.has-class \expanded and f.data \uiResizable # cleanup & close
              @close!
            else # open & re-create if necessary
              make-resizable f
              @set-draft!
              @edit-mode! # back to reply mode
              @editor.focus!
          false
      #}}}

      ####  main  ;,.. ___  _
      # + Editor
      @editor = new Editor {locals:{id:active-thread-id?}}, \#editor, @
      @editor.render!attach!

    _draft: ~>
      const forum-id  = window.active-forum-id or @context-forum-id
      const parent-id = if @is-creating-thread! then \0 else (window.active-thread-id or @context-thread-id)
      const draft-key = "post-#{window.user.id}-#{forum-id}-#{parent-id}"
      {forum-id, parent-id, draft-key}
    delete-draft: ~>
      {forum-id, parent-id, draft-key} = @_draft!
      storage.del draft-key
    save-draft: ~>
      {forum-id, parent-id, draft-key} = @_draft!
      if v = (@@$ '.PostDrawer [name="body"]')?val!
        storage.set draft-key, v
    set-draft: ~>
      {forum-id, parent-id, draft-key} = @_draft!
      if draft = storage.get draft-key # retrieve
        @set-body draft
      else
        @set-body '' # no draft
      @editor.refresh-preview!

    toggle:  ~> if @is-open! then @close! else @open!
    is-open: ~> @footer!has-class \expanded
    open: ->
      make-resizable @footer!
      # setup Editor
      <~ set-timeout _, 50ms
      unless @is-creating-thread! or @is-editing! then thread-mode false # remove title
      if is-forum-homepage window.location.pathname then thread-mode! # new thread
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
        $ \.save .html \Edit
        $f.attr \method, \put
        $f.attr \action, "/resources/posts/#{id}"
        \edit
      else # reply mode
        $ \.save .html \Reply
        $f.attr \method, \post
        $f.attr \action, \/resources/posts
        \reply

    set-body: (body) ->
      @@$ '.PostDrawer [name="body"]' .val body
    set-post: (p) ~>
      @editor.clear! # reset preview, etc...
      @set-body p.body
      $f = @@$ \.form:first # setup mock form for:
      @edit-mode p.id
      if p.title # top-level post; so--bring out title
        thread-mode!
        @@$ '[name="title"]'     .val p.title

      @@$ '[name="forum_id"]'  .val p.forum_id
      @@$ '[name="parent_id"]' .val p.parent_id
      @@$ '[name="id"]'        .val p.id

      @editor.refresh-preview!

    on-detach: ->
      @@$ \.onclick-footer-toggle .off \click.post-drawer
      @$.off!
      @close!
      @editor.detach!
      @editor = void
      try super ...


function make-resizable footer
  p = window?get-prefs!
  if p then [_, _, h?] = p
  footer # setup footer for "open state"
    ..height h or \200 # default
    ..add-class \expanded
  unless footer.data \uiResizable # guard
    footer # create initial state
      ..resizable(
        handles: \n
        min-height: 100px
        max-height: 600px
        resize: (el, ui) -> window?save-ui!)

# vim:fdm=marker
