require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Auth extends Component
    # attributes
    component-name: \Auth
    template: templates.Auth

    # static methods

    # helper to construct an Auth component and show it
    @show-login-dialog = ->
      lazy-load (-> window.$.fn.complexify), "#{window.cache-url}/local/jquery.complexify.min.js", [], ~>
        window._auth             = new Auth locals: {site-name: window.site-name}, $('#auth')
        window._auth.after-login = Auth.after-login if Auth.after-login
        window._auth.attach!

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

    # helper for wrapping event handlers in a function that requires authentication first
    @require-login = (fn) ->
      ->
        if window.user
          fn.apply window, arguments
        else
          Auth.show-login-dialog!
          false

    # constructor
    ->
      super ...

    on-attach: !~>
      @$.find '.social a' .click @open-oauth-window
      @$.on \submit '.login form' @login
      @$.on \submit '.register form' @register
      @$.on \submit '.forgot form' @forgot-password
      @$.on \submit '.reset form' @reset-password
      @$.on \click '.toggle-password' @toggle-password
      @$.on \submit '.choose form' @choose

      # XXX - do this outside, not here
      #@$.on \click \.require-login ch.require-login(-> this.click)

    on-detach: !~>

    # open window for 3rd party authentication
    open-oauth-window: (ev) ~>
      url = $(ev.target).attr \href
      window.open url, \popup, "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"
      false

    # handler for login form
    login: (ev) ~>
      $form = $ ev.target
      u = $form.find('input[name=username]')
      p = $form.find('input[name=password]')
      params =
        username: u.val!
        password: p.val!
      $.post $form.attr(\action), params, (r) ~>
        if r.success
          $.fancybox.close!
          @after-login! if @after-login
        else
          $fancybox = $form.parents \.fancybox-wrap:first
          $fancybox.add-class \on-error
          $fancybox.remove-class \shake
          show-tooltip $form.find(\.tooltip), 'Try again!' # display error
          set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100ms
      false

    # After a login, different webapps may want to do differnt things.
    after-login: ~>
      # This may be overridden after construction.

    # TODO - what am I going to do about
    # - switch-and-focus
    # - show-tooltip
    # - shake-dialog
    register: (ev) ~>
      $form = $ ev.target
      $form.find(\input).remove-class \validation-error
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          $form.find("input:text,input:password").remove-class(\validation-error).val ''
          switch-and-focus \on-register \on-validate ''
        else
          msgs = []
          r.errors?for-each (e) ->
            $e = $form.find("input[name=#{e.param}]")
            $e.add-class \validation-error .focus! # focus control
            msgs.push e.msg
          show-tooltip $form.find(\.tooltip), msgs.join \<br> # display errors
          shake-dialog $form, 100ms
      false

    # handler for form that asking for a password reset email
    forgot-password: (ev) ~>
      $form = $ ev.target
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          $.fancybox.close!
          # XXX - this should show a message telling them to check their email for a password reset link
          #@after-login! if @after-login
          #window.location.hash = ''
        else
          $form.find \input:first .focus!
          show-tooltip $form.find(\.tooltip), r.msg # display error
          shake-dialog $form, 100ms
      false

    # handler for form for resetting a forgotten password
    reset-password: ~>
      console.log \reset-password
    toggle-password: ~>
      console.log \toggle-password
    choose: ~>
      console.log \choose

/*

#{{{ Login & Authentication
window.shake-dialog = ($form, time) ->
  $fancybox = $form.parents(\.fancybox-wrap:first) .remove-class \shake
  set-timeout (-> $fancybox.add-class(\shake)), 100ms

$d.on \click \.onclick-login -> ch.show-login-dialog!; false

# register action
# login action
window.login = ->
  $form = $(this)
  u = $form.find('input[name=username]')
  p = $form.find('input[name=password]')
  params =
    username: u.val!
    password: p.val!
  $.post $form.attr(\action), params, (r) ->
    if r.success
      $.fancybox.close!
      after-login!
    else
      $fancybox = $form.parents \.fancybox-wrap:first
      $fancybox.add-class \on-error
      $fancybox.remove-class \shake
      show-tooltip $form.find(\.tooltip), 'Try again!' # display error
      set-timeout (-> $fancybox.add-class(\shake); u.focus!), 100ms
  false

# get the user after a successful login
window.after-login = ->
  window.user <- $.getJSON \/auth/user
  onload-personalize!
  if user and mutants?[window.mutator]?on-personalize
    mutants?[window.mutator]?on-personalize window, user, ->
      socket?disconnect!
      socket?socket?connect!

# logout
window.logout = ->
  window.location = \/auth/logout; false # for intelligent redirect
$d.on \click \.onclick-logout -> window.logout!; false

# register
window.register = ->
  $form = $(this)
  $form.find(\input).remove-class \validation-error
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $form.find("input:text,input:password").remove-class(\validation-error).val ''
      switch-and-focus \on-register \on-validate ''
    else
      # NOTE:  Only the last tooltip is shown and only the last input is focused.
      r.errors?for-each (e) ->
        $e = $form.find("input[name=#{e.param}]")
        $e.add-class \validation-error .focus!    # focus control
        show-tooltip $form.find(\.tooltip), e.msg # display error
      shake-dialog $form, 100ms
  false

# choose a username
window.choose = ->
  $form = $ this
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $.fancybox.close!
      after-login!
      window.location.hash = ''
    else
      $form.find \input:first .focus!
      show-tooltip $form.find(\.tooltip), r.msg # display error
      shake-dialog $form, 100ms
  false

# forgot password
window.forgot-password = ->
  $form = $ this
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      show-tooltip $form.find(\.tooltip), "Recovery link emailed!"
    else
      show-tooltip $form.find(\.tooltip), "Email not found."
      shake-dialog $form, 100ms
  return false

window.show-reset-password-dialog = ->
  $form = $ '#auth .reset form'
  ch.show-login-dialog!
  set-timeout (-> switch-and-focus '', \on-reset, '#auth .reset input:first'), 500ms
  hash = location.hash.split('=')[1]
  $form.find('input[type=hidden]').val(hash)
  $.post '/auth/forgot-user', { forgot: hash }, (r) ->
    if r.success
      $form .find 'h2:first' .html 'Choose a New Password'
      $form .find('input').prop('disabled', false)
    else
      $form .find 'h2:first' .html "Couldn't find you. :("

window.reset-password = ->
  $form = $ this
  password = $form.find('input[name=password]').val!
  if password.match /^\s*$/
    show-tooltip $form.find(\.tooltip), "Password may not be blank."
    return false
  $.post $form.attr(\action), $form.serialize!, (r) ->
    if r.success
      $form.find('input').prop(\disabled, true)
      show-tooltip $form.find(\.tooltip), "Password changed!"
      location.hash = ''
      $form.find('input[name=password]').val('')
      set-timeout ( ->
        switch-and-focus \on-reset, \on-login, '#auth .login input:first'
        show-tooltip $('#auth .login form .tooltip'), "Now log in!"
      ), 1500ms
    else
      show-tooltip $form.find(\.tooltip), "Choose a better password."
  return false

$d.on \submit '.login form' login
$d.on \submit '.register form' register
$d.on \submit '.forgot form' forgot-password
$d.on \submit '.choose form' choose
$d.on \submit '.reset form' reset-password
$d.on \click \.require-login ch.require-login(-> this.click)

# 3rd-party auth
$ '.social a' .click ->
  url = $ this .attr(\href)
  window.open url, \popup, "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"
  false
#}}}

*/
