define = window?define or require(\amdefine) module
require, exports, module <- define

if window?
  require! { $: \jquery }

{render-and-append} = require \../shared/shared-helpers

#{{{ Editing Posts
@post-success = (ev, data) ~>
  e = $ ev.target
  f = e.closest \.post-edit # form
  p = f.closest \.editing # post being edited
  t = e.find \.tooltip
  unless data.success
    @show-tooltip t, data?errors?join \<br>
    e.find \textarea:first .focus!
  else
    # render updated post
    p.find \.title .html data.0?title
    p.find \.body  .html data.0?body
    f.remove-class \fadein .hide 300s # & hide
    meta = furl.parse window.location.pathname
    window.last-statechange-was-user = false # flag that this was programmer, not user
    switch meta.type
    | \new-thread => History.replace-state {} '' data.uri
    | \edit       => @remove-editing-url meta
    # close drawer & cleanup
    window.component.postdrawer?detach!
    window.component.postdrawer = void
    $ '#post_new .fadein' .remove!
  false

@submit-form = (ev, fn) ~>
  $f = $ ev.target .closest \form # get event's form
  form-data = if $f?length
    $f.serialize!
  else # mock form (eg. PostDrawer's Editor is outside a <form>)
    $f = $ ev.target.closest \.form
    [encodeURI("#k=#v&") for k,v of {
      body:     ($f.find '[name="body"]' .val!)
      title:    ($f.find '[name="title"]' .val!)
      id:       ($f.find '[name="id"]' .val!)
      parent_id:($f.find '[name="parent_id"]' .val!)
      forum_id: ($f.find '[name="forum_id"]' .val!)}].join('').replace /,$/, ''

  # disable inputs
  $s = $ $f.find '[type=submit]:first'
  if $s then $s.attr \disabled \disabled
  $.ajax { # submit!
    url:  $f.attr \action
    type: $f.attr \method
    data: form-data
    data-type: \json
    success:   (data) ~>
      $s.remove-attr \disabled # re-enable
      @show-tooltip $($f.find \.tooltip), data?msg or 'Try again!'
      if fn then fn.call $f, data
    error: (data) ~>
      $s.remove-attr \disabled # re-enable
      @show-tooltip $($f.find \.tooltip), data?msg or 'Try again!'
  }
  set-timeout (-> $f.find \input.title .focus!), 100ms # focus!
  false

# handle in-line editing
focus  = ($e) -> set-timeout (-> $e.find 'input[type="text"]' .focus!), 10ms
render = (sel, locals, cb=(->)) ~>
  $e = $ sel
  render-and-append window, sel, \post-edit, {user:user, post:locals}, ($e) ->
    cb!
    focus $e

@postdrawer = ~>
  return pd if pd = window.component.postdrawer # guard
  window.component.postdrawer = new PostDrawer {locals:{
    forum-id:window.active-forum-id,
    parent-id:window.active-thread-id}}, \#post_new

@toggle-postdrawer = (ev) ~>
  # guards
  if ev # XXX pass-through programatical calls
    unless $ ev.target .has-class \onclick-footer-toggle then return
  unless (window.user?rights?super or window.user?sys_rights?super)
    if $ \body .has-class \locked then return
  unless user then Auth.show-login-dialog!; return
  @postdrawer!toggle!

@open-postdrawer = (ev) ~> @postdrawer!open!

# thread mode toggles between top-level posts w/ a title
@thread-mode = (mode=true) ~>
  $ \footer .toggle-class \thread, mode
  $ '[name="title"]' .val ''
  $ '[name="forum_id"]' .val active-forum-id       # set forum
  unless mode then @postdrawer!set-edit-mode false # disable edit mode
@in-thread-mode = -> ($ \footer .has-class \thread) and ($ \footer .has-class \expanded)

@edit-post = (id) ~>
  if id is true # render new
    scroll-to-top!
    $ \html .add-class \new # for stylus
    @postdrawer!clear!
    @thread-mode!
    @open-postdrawer!
  else # fetch existing & edit
    sel = "\#post_#{id}"
    e   = $ sel
    @thread-mode false
    $.get "/resources/posts/#{id}" (p) ~>
      # setup & open post drawer
      @postdrawer!set-post p
      @open-postdrawer!
#}}}
#{{{ Lazy loading
load-css-cache = {}
load-css = (href) ->
  return if load-css-cache[href] # guard
  $ \head .append($ '<link rel="stylesheet" type="text/css">' .attr(\href, href))
  load-css-cache[href] = true

@lazy-load = (test, script, css, cb) ~>
  b = $ \body
  b.add-class \waiting
  unless test!
    if css then load-css css
    <- require [script]
    b .remove-class \waiting
    cb!
  else
    b .remove-class \waiting
    cb!
@lazy-load-autosize = (cb) ~>
  @lazy-load (-> window.$!fn?autosize),
    "#cache-url/local/jquery.autosize.min.js",
    null,
    cb
@lazy-load-nested-sortable = (cb) ~>
  @lazy-load (-> window.$!nested-sortable?length),
    "#cache-url/local/jquery.mjs.nestedSortable.js",
    null,
    cb
@lazy-load-html5-uploader = (cb) ~>
  @lazy-load (-> window.$!html5-uploader?length),
    "#cache-url/local/jquery.html5uploader.js",
    "#cache-url/local/editor/skins/moono/editor.css",
    cb
@lazy-load-jcrop = (cb) ~>
  @lazy-load (-> window.$!Jcrop?length),
    "#cache-url/jcrop/js/jquery.Jcrop.min.js",
    "#cache-url/jcrop/css/jquery.Jcrop.min.css",
    cb
@lazy-load-complexify = (cb) ~>
  @lazy-load (-> window.$.fn.complexify),
    "#cache-url/local/jquery.complexify.min.js"
    null,
    cb
@lazy-load-fancybox = (cb) ~>
  @lazy-load (-> window.$!fancybox?length),
    "#cache-url/fancybox/jquery.fancybox.pack.js",
    "#cache-url/fancybox/jquery.fancybox.css",
    cb
@lazy-load-socketio = (cb) ~>
  @lazy-load (-> window.$!fancybox?length),
    "#cache-url/local/socket.io.min.js",
    null,
    cb
#}}}

@storage = # use local storage
  del: (k)    -> local-storage.remove-item k
  get: (k)    -> try local-storage.get-item k |> JSON.parse
  has: (k)    -> local-storage.has-own-property k
  set: (k, v) -> local-storage.set-item k, JSON.stringify v

@fancybox-params =
  close-effect: \elastic
  close-speed:  200ms
  close-easing: \easeOutExpo
  open-effect:  \fade
  open-speed:   450ms

@respond-resize = ~>
  w = $ window
  # augment stylus for height
  if e = $ \.thread.active
    switch e.height!
    | 54 => # one-liner title
      e.add-class \small
      e.remove-class 'medium large x-large'
    | 76 => # most variations fit into medium
      e.add-class \medium
      e.remove-class 'small large x-large'
    | 98 => # long title & narrow nav
      e.add-class \large
      e.remove-class 'small medium x-large'
    | 120 => # 3 or 4 row title
      e.add-class \x-large
      e.remove-class 'small medium large'
    e.remove-class \hidden

  unless window.mutator is \admin # FIXME improve responsive.styl
    if w.width! <= 800px then $ \body .add-class \collapsed

@set-wide = ~>
  l = $ \#left_content
  l.toggle-class \wide (l.width! > 300px)

@align-ui = ->
  # breadcrumb to width
  b = $ \#breadcrumb
  m = $ \#main_content
  l = $ \#left_content
  pos = (m.width!-b.width!)/2
  b.transition {left:(if pos < l.width! then l.width! else pos)}, 300ms \easeOutExpo
  # footer to left-nav
  $ \footer .css \left, ($ \#left_container .width!+1+\px)

@remove-editing-url = (meta) ~>
  History.replace-state {no-surf:true} '' meta.thread-uri

@mutate = ->
  $e = $ this
  return if $e.has-class \require-login and !user # guard
  href = $e .data \href or $e .attr \href
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
@show-tooltip = ($tt, msg, duration=4500ms) ~>
  key = $tt.attr \id # keyed to tooltip id
  if $tt?length
    unless msg?length then $tt.remove-class \hover; return # hide & guard
    timer = timers[key]
    if timer then clear-timeout timer
    $tt.html msg .add-class \hover # show
    timers[key] = set-timeout (-> timers[key]=void; $tt.remove-class \hover), duration # remove

@switch-and-focus = (remove, add, focus-on) ~>
  $e = $ \.fancybox-wrap
  $e.remove-class("#remove shake slide").add-class(add)
  set-timeout (-> # animate & yield before focus, so smooth!
    $e.add-class \slide
    set-timeout (-> $ focus-on .focus!select!), 250ms), 50ms

@set-online-user = (id) ~>
  $ "[data-user-id=#{id}] .profile.photo"
    ..add-class \online
    ..attr \title, \Online!

@set-profile = (src) ~> # top-right profile/login area
  $ '.tools > .photo'
    ..attr \href "/user/#{user.name}"
    ..add-class \online # set online!
    ..attr \title user.name
  $ \#profile
    ..on   \load -> $ 'header .profile' .show!css \opacity, 1
    ..attr \src, window.cache-url + src

@set-imgs = ~>
  # apply src attrs to images with data attrs (speeds up DOM-ready)
  $ 'img[data-src]' .each ->
    e = $ this
      ..css \opacity, 0
      ..attr \src, e.data \src
      ..load ->
        e.remove-attr \data-src # cleanup
        e.transition opacity:1, 800ms

@
# vim:fdm=marker
