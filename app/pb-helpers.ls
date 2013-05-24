# XXX shared by pb-mutants & pb-entry

timers = {}

@show-tooltip = ($tooltip, msg, duration=3000ms) ->
  timer = timers[msg]
  if timer then clear-timeout timer
  $tooltip.html msg .add-class \hover # show
  timers[msg] = set-timeout (-> timers[msg]=void; $tooltip.remove-class \hover), duration # remove

@set-online-user = (id) ->
  $ "[data-user-id=#{id}] .profile.photo" .add-class \online

# double-buffered replace of view with target
@render-and = (fn, w, target, tmpl, params, cb) -->
  $t = w.$ target  # target
  $b = w.$ \<div>  # buffer
  $b.hide!
  $t[fn] $b
  w.jade.render $b.0, tmpl, params
  $b.show!add-class \fadein
  set-timeout (-> cb $b), 100ms # XXX race condition
@render-and-append  = @render-and \append
@render-and-prepend = @render-and \prepend

@is-forum-homepage = (path) ->
  furl.parse path .type is \forum
@is-editing = (path) ->
  meta = furl.parse path
  switch meta.type
  | \new-thread => true
  | \edit       => meta.id
  | otherwise   => false

@remove-editing-url = (meta) ->
  History.replace-state {no-surf:true} '' meta.thread-uri

@scroll-to-edit = (cb) ->
  cb = -> noop=1 unless cb
  id = is-editing window.location.pathname
  if id then # scroll to id
    awesome-scroll-to "\#post_#{id}" 600ms cb
    true
  else
    scroll-to-top cb
    false

# handle in-line editing
@edit-post = (id, data={}) ->
  focus  = ($e) -> set-timeout (-> $e.find 'input[type="text"]' .focus!), 100ms
  render = (sel, locals) ~>
    $e = $ sel
    @render-and-append window, sel, \post-edit, {user:user, post:locals}, ($e) ->
      # init sceditor
      $e.find \textarea.body .sceditor(
        plugins:        \bbcode
        style:          "#{window.cache-url}/local/jquery.sceditor.default.min.css"
        toolbar:        'bold,italic,underline|image,link,youtube|emoticon|source'
        width:          \85%
        emoticons-root: "#{window.cache-url}/")
      $e.find \.sceditor-container .prepend($e.find \.title) # place title inside
      focus $e

  if id is true # render new
    scroll-to-top!
    data.action = \/resources/post
    data.method = \post
    render \.forum, data
  else # fetch existing & render
    sel = "\#post_#{id}"
    e   = $ sel
    unless e.find("\#post_edit_#{id}:visible").length # guard
      scroll-to-edit!
      $.get "/resources/posts/#{id}" (p) ->
        render sel, p
        e .add-class \editing
    else
      focus e

@submit-form = (event, fn) -> # form submission
  $f = $ event.target .closest(\form) # get event's form
  $s = $ $f.find('[type=submit]:first')
  $s.attr \disabled \disabled

  # update textarea body from sceditor
  $e = $ \textarea.body
  $e.html $e.data!sceditor?val! if $e.length and $e.data!sceditor

  $.ajax {
    url:      $f.attr(\action)
    type:     $f.attr(\method)
    data:     $f.serialize!
    data-type: \json
    success:  (data) ->
      if fn then fn.call $f, data
    error: ->
      $s.remove-attr \disabled
      show-tooltip $($f.find \.tooltip), 'Try again!'
  }
  false

@respond-resize = ->
  w = $ window
  if w.width! <= 800px then $ \body .add-class \collapsed

@align-breadcrumb = ->
  b = $ \#breadcrumb
  m = $ \#main_content
  l = $ \#left_content
  pos = (m.width!-b.width!)/2
  b.transition {left:(if pos < l.width! then l.width! else pos)}, 300ms \easeOutExpo

@flip-background = (w, cur, direction=\down) ->
  clear-timeout w.bg-anim if w.bg-anim
  last = w.$ \.bg.active
  next = w.$ \#forum_bg_ + cur.data \id
  next.css \display \block
  unless last.length
    next.add-class \active
  else
    w.bg-anim := set-timeout (->
      last.css \top if direction is \down then -300 else 300 # stage animation
      last.remove-class \active
      next.add-class \active # ... and switch!
      w.bg-anim = 0
    ), 100

# vim:fdm=indent
