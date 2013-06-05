export show-login-dialog = ->
  $.fancybox.open \#auth,
    close-effect: \elastic
    close-speed:  200ms
    close-easing: \easeOutExpo
    open-effect: \fade
    open-speed: 300ms
  set-timeout (-> $ '#auth input[name=username]' .focus! ), 100ms

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

export scroll-to-edit = (cb) ->
  cb = -> noop=1 unless cb
  id = is-editing window.location.pathname
  if id then # scroll to id
    awesome-scroll-to "\#post_#{id}" 600ms cb
    true
  else
    scroll-to-top cb
    false

