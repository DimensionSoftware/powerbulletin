define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
require! \./Editor
require! furl: \../shared/forum-urls

{lazy-load-html5-uploader, in-thread-mode, thread-mode, storage, submit-form, post-success} = require \../client/client-helpers
{is-forum-homepage} = require \../shared/shared-helpers

module.exports =
  class PostDrawer extends PBComponent

    editor: void
    footer: ~> @@$ \footer

    on-attach: !~>
      #{{{ Event Delegates
      @@$ '.in-reply, .in-edit' .on \click scroll-to-top
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
          @delete-draft!

      # make entire component droppable
      opts = {
        name: \upload
        post-url: "/resources/sites/#{site.id}/upload"
        on-failure: (ev, file, req) ~>
          try r = JSON.parse req.response-text
          if req.status is 400
            show-tooltip (@$.find \.tooltip), r?msg or 'File must be at least 200x200px'
        on-success: (xhr, file, r-json) ~>
          r = JSON.parse(r-json)
          cache-buster = Math.random!to-string!replace \\. ''
          #@$.find \img .attr \src, "#{cacheUrl}#{r.url}?#cache-buster"
      }
      <~ lazy-load-html5-uploader
      @$.html5-uploader opts # make entire component droppable

      @@$ document .on \click.post-drawer (ev) ~> # live
        if $ ev.target .has-class \onclick-footer-toggle # guard
          @context-forum-id = ($ ev.target .parents '[data-forum-id]').data \forum-id
          if in-thread-mode!
            if @is-editing! # if editing, hold drawer open & switch modes
              thread-mode false # replies don't have titles
              @edit-mode! # back to default Reply mode
              if @editor
                @editor
                  ..clear!
                  ..focus!
            else
              if @is-open! then @close! # toggle
          else
            if @is-open! then @close! # toggle
            @clear! # back to Reply mode
            thread-mode false
            make-resizable @footer!
            @set-draft!
            @edit-mode! # back to reply mode
            if @editor then @editor.focus!
          false
      #}}}

      ####  main  ;,.. ___  _
      # + Editor
      @editor = new Editor {locals:{id:active-thread-id?}}, \#editor, @
      @editor.render!attach!

    _draft: ~>
      const forum-id  = window.active-forum-id or @context-forum-id
      const parent-id = if @is-creating-thread! then \0 else (window.active-thread-id or @context-thread-id)
      const draft-key = "post-#{window.user?id}-#{forum-id}-#{parent-id}"
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
      @editor?refresh-preview!

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

    focus: ~> @editor?focus!
    clear: ~> # clear all inputs
      @editor?clear!
      @@$ '[name="title"]'     .val ''
      @@$ '[name="forum_id"]'  .val ''
      @@$ '[name="parent_id"]' .val ''
      @@$ '[name="id"]'        .val ''
      @@$ \#action_wrapper .remove-class 'reply edit' # clear ui action
      @edit-mode! # back to reply mode
    is-creating-thread: ~> (furl.parse window.location.pathname)?type is \new-thread
    is-editing: ~> (@@$ \.form:first .attr \method) is \put
    set-creating-mode: ~>
      $ \.save .html \Create
      @@$ \#action_wrapper .toggle-class \reply, false
      @@$ \#action_wrapper .toggle-class \edit,  false
    edit-mode: (id) ~>
      if @is-creating-thread! then History.replace-state {}, '', ($ '.threads .active a' .attr \href)
      $f = @@$ \.form:first # setup mock form for:
      if id # edit mode
        $ \.save .html \Edit
        $f.attr \method, \put
        $f.attr \action, "/resources/posts/#{id}"
        # show action is "edit"
        @@$ \#action_wrapper .toggle-class \reply, false
        @@$ \#action_wrapper .toggle-class \edit,  true
        \edit
      else # reply mode
        $f.attr \method, \post
        $f.attr \action, \/resources/posts
        if @is-creating-thread!
          # show action is "new"
          @set-creating-mode!
          \new-thread
        else
          $ \.save .html \Reply
          # show action is "reply"
          @@$ \#action_wrapper .toggle-class \reply, true
          @@$ \#action_wrapper .toggle-class \edit,  false
          \reply

    set-body: (body) ->
      @@$ '.PostDrawer [name="body"]' .val body
      # use marshalled data to fill-out
      if @is-creating-thread!
        @set-creating-mode!
      else # use marshalled for body title?
        if window.reply-to and window.reply-by
          @@$ \#reply_to .html "<a>#{window.reply-to}</a>"
          @@$ \#reply_by .html "<a>#{window.reply-by}</a>"

    set-post: (p) ~>
      unless p then return # guard
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

      @editor?refresh-preview!

    on-detach: ->
      @@$ document .off \click.post-drawer
      @$.off!
      @close!
      @editor.detach!
      @editor = void
      try super ...


function make-resizable footer
  p = window?get-prefs!
  if p then [_, _, h?] = p
  footer # setup footer for "open state"
    ..height h or \400 # default
    ..add-class \expanded
  unless footer.data \uiResizable # guard
    footer # create initial state
      ..resizable(
        handles: \n
        min-height: 100px
        max-height: 600px
        resize: (el, ui) -> window?save-ui!)

# vim:fdm=marker
