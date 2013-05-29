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
