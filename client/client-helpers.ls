define = window?define or require(\amdefine) module
define (require, exports, module) ->
  #{{{ Editing Posts
  export post-success = (ev, data) ->
    f = $ ev.target .closest \.post-edit # form
    p = f.closest \.editing # post being edited
    t = $(f.find \.tooltip)
    unless data.success
      show-tooltip t, data?errors?join \<br>
    else
      # render updated post
      p.find \.title .html data.0?title
      p.find \.body  .html data.0?body
      f.remove-class \fadein .hide 300s # & hide
      meta = furl.parse window.location.pathname
      window.last-statechange-was-user = false # flag that this was programmer, not user
      switch meta.type
      | \new-thread => History.replace-state {} '' data.uri
      | \edit       => remove-editing-url meta
    false

  export ck-submit-form = (e) ->
    editor = e?element?$
    ev = {target:editor} # mock event
    unless editor?id # editing, so--build post
      $p = $ editor .closest \.post
      $.ajax {
        url: \/resources/posts/ + $p.data \post-id
        type: \put
        data:
          id:        $p.data \post-id
          forum_id:  $p.data \forum-id
          parent_id: $p.data \thread-id
          body:      e.get-data!
        success: (data) ->
          e.fire \blur
          $p.find '[contentEditable=true]' .blur!
      }
    else
      submit-form ev, (data) -> # ...and sumbit!
        post-success ev, data
        # close & cleanup drawer
        $ \footer .remove-class \expanded
        $ '#post_new .fadein' .remove!

  export submit-form = (ev, fn) ->
    $f = $ ev.target .closest(\form) # get event's form
    $s = $ $f.find('[type=submit]:first')
    if $s then $s.attr \disabled \disabled

    # is body in ckeditor?
    body = $f.find \textarea.body
    e    = CKEDITOR?instances?[body.attr \id]
    if e
      input = e.get-data!
      if input?length
        body.val input # fill-in
        e.set-data ''  # clear

    $.ajax { # submit!
      url:       $f.attr \action
      type:      $f.attr \method
      data:      $f.serialize!
      data-type: \json
      success:   (data) ->
        $s.remove-attr \disabled
        if $ \footer .has-class \expanded then $ '.onclick-footer-toggle:first' .click! # close drower
        if fn then fn.call $f, data
      error: (data) ->
        $s.remove-attr \disabled
        show-tooltip $($f.find \.tooltip), data?msg or 'Try again!'
    }
    false

  # makes entire page inline-editable for user-id
  export set-inline-editor = (user-id) ->
    $ ".post[data-user-id=#user-id] .post-content"
      .attr \contentEditable true
    <- lazy-load-editor
    for e in CKEDITOR.instances then e.destroy true # cleanup
    try CKEDITOR.inline-all!

  # handle in-line editing
  focus  = ($e) -> set-timeout (-> $e.find 'input[type="text"]' .focus!), 10ms
  render = (sel, locals, cb=(->)) ~>
    $e = $ sel
    render-and-append window, sel, \post-edit, {user:user, post:locals}, ($e) ->
      cb!
      focus $e
  export toggle-post = (ev) ->
    unless $ ev?target .has-class \onclick-footer-toggle then return # guard
    unless user then Auth.show-login-dialog!; return # guard
    data =
      action: \/resources/posts
      method: \post
    # setup form
    e = $ \footer
    if e.has-class \expanded # close drawer & cleanup
      e.remove-class \expanded
      #try CKEDITOR.instances.post_new.destroy true
      $ '#post_new .fadein' .remove!
    else # bring out drawer & init+focus editor
      e.add-class \expanded
      render \#post_new, data, -> # init form
        <- lazy-load-editor
        unless CKEDITOR.instances.post_new
          CKEDITOR.replace ($ '#post_new textarea' .0)#, {startup-focus:true}
        e.find 'form.post-new input[name="forum_id"]' .val window.active-forum-id
        e.find 'form.post-new input[name="parent_id"]' .val window.active-thread-id
  export edit-post = (id, data={}) ->
    if id is true # render new
      scroll-to-top!
      data.action = \/resources/posts
      data.method = \post
      render \.forum, data, -> # init editor on post
        <- lazy-load-editor
        CKEDITOR.replace($ \#editor .0)
    else # fetch existing & edit
      sel = "\#post_#{id}"
      e   = $ sel
      unless e.find("\#post_edit_#{id}:visible").length # guard
        #awesome-scroll-to "\#post_#{id}" 600ms
        $.get "/resources/posts/#{id}" (p) ->
          render sel, p
          e .add-class \editing
      else
        focus e
  #}}}
  #{{{ Lazy loading
  load-css-cache = {}
  load-css = (href) ->
    return if load-css-cache[href] # guard
    $ \head .append($ '<link rel="stylesheet" type="text/css">' .attr(\href, href))
    load-css-cache[href] = true

  export lazy-load = (test, script, css, cb) ->
    b = $ \body
    b.add-class \waiting
    unless test!
      if css then load-css css
      <- headjs script
      b .remove-class \waiting
      cb!
    else
      b .remove-class \waiting
      cb!
  export lazy-load-deserialize = (cb) ->
    lazy-load (-> window.$!deserialize?length),
      "#cache-url/local/jquery.deserialize.min.js",
      null,
      cb
  export lazy-load-nested-sortable = (cb) ->
    lazy-load (-> window.$!nested-sortable?length),
      "#cache-url/local/jquery.mjs.nestedSortable.js",
      null,
      cb
  export lazy-load-html5-uploader = (cb) ->
    lazy-load (-> window.$!html5-uploader?length),
      "#cache-url/local/jquery.html5uploader.js",
      "#cache-url/local/editor/skins/moono/editor.css",
      cb
  export lazy-load-jcrop = (cb) ->
    lazy-load (-> window.$!Jcrop?length),
      "#cache-url/jcrop/js/jquery.Jcrop.min.js",
      "#cache-url/jcrop/css/jquery.Jcrop.min.css",
      cb
  export lazy-load-editor = (cb) ->
    lazy-load (-> CKEDITOR?version),
      "#cache-url/local/editor/ckeditor.js",
      null,
      cb
  export lazy-load-fancybox = (cb) ->
    lazy-load (-> window.$!fancybox?length),
      "#cache-url/fancybox/jquery.fancybox.pack.js",
      "#cache-url/fancybox/jquery.fancybox.css",
      cb
  export lazy-load-socketio = (cb) ->
    lazy-load (-> window.io),
      "/socket.io/socket.io.js",
      null,
      cb
  #}}}

  export fancybox-params =
    close-effect: \elastic
    close-speed:  200ms
    close-easing: \easeOutExpo
    open-effect:  \fade
    open-speed:   450ms

  export respond-resize = ->
    w = $ window
    unless window.mutator is \admin # FIXME improve responsive.styl
      if w.width! <= 800px then $ \body .add-class \collapsed

  export set-wide = ->
    l = $ \#left_content
    l.toggle-class \wide (l.width! > 300px)

  export align-breadcrumb = ->
    b = $ \#breadcrumb
    m = $ \#main_content
    l = $ \#left_content
    pos = (m.width!-b.width!)/2
    b.transition {left:(if pos < l.width! then l.width! else pos)}, 300ms \easeOutExpo

  export remove-editing-url = (meta) ->
    History.replace-state {no-surf:true} '' meta.thread-uri

  export mutate = ->
    $e = $ this
    return if $e.has-class \require-login and !user # guard
    href = $e .attr \href
    return false unless href # guard
    return true if href?match /#/
    params = {}

    # surfing
    params.no-surf   = true if $e.has-class \no-surf             # no need to fetch surf data
    params.surf-data = $e.data \surf or window.surf-data or void # favor element data on click
    window.last-statechange-was-user = false # flag that this was programmer, not user
    History.push-state params, '', href
    false

  timers = {}
  export show-tooltip = ($tooltip, msg, duration=4000ms) ->
    unless msg?length then return # guard
    timer = timers[msg]
    if timer then clear-timeout timer
    $tooltip.html msg .add-class \hover # show
    timers[msg] = set-timeout (-> timers[msg]=void; $tooltip.remove-class \hover), duration # remove

  export switch-and-focus = (remove, add, focus-on) ->
    $e = $ \.fancybox-wrap
    $e.remove-class("#remove shake slide").add-class(add)
    set-timeout (-> # animate & yield before focus, so smooth!
      $e.add-class \slide
      set-timeout (-> $ focus-on .focus!), 250ms), 50ms

  export set-online-user = (id) ->
    $ "[data-user-id=#{id}] .profile.photo"
      ..add-class \online
      ..attr \title, \Online!

  export set-profile = (src) ->
    $ \.photo
      ..attr \href "/user/#{user.name}"
      ..add-class \online # set online!
    $ \#profile
      ..on   \load -> $ \.profile .show!
      ..attr \src, window.cache-url + src
# vim:fdm=marker
