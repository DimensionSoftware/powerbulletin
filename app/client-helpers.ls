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
