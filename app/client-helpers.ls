export show-login-dialog = ->
  $.fancybox.open \#auth,
    close-effect: \elastic
    close-speed:  200ms
    close-easing: \easeOutExpo
    open-effect: \fade
    open-speed: 450ms
  set-timeout (-> $ '#auth input[name=username]' .focus! ), 100ms
  # password complexity ui
  window.COMPLEXIFY_BANLIST = [\god \money \password]
  $ '#auth [name="password"]' .complexify({}, (pass, percent) ->
    e = $ this .parent!
    e.find \.strength-meter .toggle-class \strong, pass
    e.find \.strength .css(height:parse-int(percent)+\%))

export require-login = (fn) ->
  ~>
    if window.user
      fn.apply window, arguments
    else
       @show-login-dialog!
       false

export mutate = (event) ->
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
export show-tooltip = ($tooltip, msg, duration=3000ms) ->
  timer = timers[msg]
  if timer then clear-timeout timer
  $tooltip.html msg .add-class \hover # show
  timers[msg] = set-timeout (-> timers[msg]=void; $tooltip.remove-class \hover), duration # remove

export set-online-user = (id) ->
  $ "[data-user-id=#{id}] .profile.photo" .add-class \online

export submit-form = (event, fn) -> # form submission
  $f = $ event.target .closest(\form) # get event's form
  $s = $ $f.find('[type=submit]:first')
  $s.attr \disabled \disabled

  # update textarea body from sceditor
  $e = $ \textarea.body
  $e.html $e.data!sceditor?val! if $e.length and $e.data!sceditor

  # pass transient_owner as alternate auth mechanism
  # to support sandbox mode
  serialized =
    if tid = $.cookie('transient_owner')
      $f.serialize! + "&transient_owner=#tid"
    else
      $f.serialize!

  $.ajax {
    url: $f.attr(\action)
    type: $f.attr(\method)
    data: serialized
    data-type: \json
    success:  (data) ->
      $s.remove-attr \disabled
      if fn then fn.call $f, data
    error: (data) ->
      $s.remove-attr \disabled
      show-tooltip $($f.find \.tooltip), data?msg or 'Try again!'
  }
  false

export respond-resize = ->
  w = $ window
  if w.width! <= 800px then $ \body .add-class \collapsed

export align-breadcrumb = ->
  b = $ \#breadcrumb
  m = $ \#main_content
  l = $ \#left_content
  pos = (m.width!-b.width!)/2
  b.transition {left:(if pos < l.width! then l.width! else pos)}, 300ms \easeOutExpo

export remove-editing-url = (meta) ->
  History.replace-state {no-surf:true} '' meta.thread-uri

# handle in-line editing
export edit-post = (id, data={}) ->
  focus  = ($e) -> set-timeout (-> $e.find 'input[type="text"]' .focus!), 100ms
  render = (sel, locals, cb=(->)) ~>
    $e = $ sel
    @render-and-append window, sel, \post-edit, {user:user, post:locals}, ($e) ->
      cb!
      focus $e

  if id is true # render new
    console.log \create-new
    scroll-to-top!
    data.action = \/resources/post
    data.method = \post
    render \.forum, data, -> # init ckeditor on post!
      init-editor = -> CKEDITOR.replace($ '#post_edit_0 textarea' .0)
      unless CKEDITOR?version # lazy-load
        <- $.get-script "#cache-url/local/editor/ckeditor.js"
        init-editor!
      else
        init-editor!
  else # fetch existing & edit
    console.log \fetch
    sel = "\#post_#{id}"
    e   = $ sel
    unless e.find("\#post_edit_#{id}:visible").length # guard
      awesome-scroll-to "\#post_#{id}" 600ms
      $.get "/resources/posts/#{id}" (p) ->
        console.log \editing: + p
        render sel, p
        e .add-class \editing
    else
      focus e
