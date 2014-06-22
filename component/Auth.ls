define = window?define or require(\amdefine) module
require, exports, module <- define
require! \./PBComponent

{switch-and-focus, show-info, show-tooltip, lazy-load-complexify, lazy-load-fancybox} = require \../client/client-helpers if window?
{unique} = require \prelude-ls

module.exports =
  class Auth extends PBComponent
    # attributes
    component-name: \Auth

    # static methods

    # helper to construct an Auth component and show it
    @hide-info = -> $ \#info .hide!

    @show-login-dialog = (cb=(->)) ->
      @@hide-info!
      <~ lazy-load-fancybox
      <~ lazy-load-complexify
      if not window._auth
        window._auth             = new Auth locals: {site-name: window.site-name, invite-only:window.invite-only, auth-domain: window.auth-domain, current-url: window.location.to-string! }, $ \#auth
        window._auth.after-login = Auth.after-login if Auth.after-login
      else
        window._auth.update-social-links!

      $.fancybox.open \#auth, {before-close: -> Auth.hide-info!} <<< window.fancybox-params unless $ \.fancybox-overlay:visible .length
      set-timeout (-> $ \#login-email .focus!select! ), 350ms
      # password complexity ui
      window.COMPLEXIFY_BANLIST = [\god \money \password \love]
      $ '#auth [name="password"]' .complexify({}, (pass, percent) ->
        e = $ this .parent!
        e.find \.strength-meter .toggle-class \strong, pass
        e.find \.strength .css(height:parse-int(percent)+\%))
      cb window._auth.$

    @show-choose-dialog = ->
      <- Auth.show-login-dialog
      switch-and-focus '', \on-choose, '.choose input:first'

    @show-info-dialog = (msg, msg2='', remove='', cb=(->)) ->
      @@hide-info!
      <- Auth.show-login-dialog
      fb = $ \.fancybox-wrap:first
      fb.find \#msg .html msg
      fb.find '.dialog .msg2' .html msg2
      switch-and-focus remove, \on-dialog, ''
      cb window._auth.$

    @show-register-dialog = (remove='', cb=(->)) ->
      <- Auth.show-login-dialog
      switch-and-focus remove, \on-register, '.register input:first'
      show-info 0, [\#auth, '''
        Generate a Secure Password and Forget About It!
        <br/>
        <small>Click Forgot later and we'll email you a single-use <b>Secure Login Link</b></small>
        ''']
      cb window._auth.$

    @show-reset-password-dialog = ->
      @@hide-info!
      $auth <- Auth.show-login-dialog
      $form = $auth .find('.reset form')
      switch-and-focus '', \on-reset, '#auth .reset input:first'
      hash = location.hash.split('=')[1]
      $form.find('input[type=hidden]').val(hash)
      $.post '/auth/forgot-user', { forgot: hash }, (r) ->
        if r.success
          $ \#password .val '' # blank password
          $form .find 'h2:first' .html 'Choose a New Password'
          $form .find('button,input').prop('disabled', false)
        else
          $form .find 'h2:first' .html "Couldn't find you. :("

    @login-with-token = (cb) ->
      r <- cors.get "#{auth-domain}/auth/once", { site_id: window.site-id }
      #console.warn \cors, r
      if r
        rr <- $.post '/auth/once', { token: r.token }
        #console.warn \once, rr
        if rr.success
          Auth.after-login!
          window.location.hash = ''
          if cb then return cb!
        #else
          #console.error 'local /auth/once failed'
      #else
        #console.error 'remote /auth/once failed'

    # helper for wrapping event handlers in a function that requires authentication first
    @require-login = (fn, cb) ->
      if cb
        @@require-login-cb = cb
      ->
        if window.user
          fn.apply window, arguments
        else
          Auth.show-login-dialog!
          false

    @require-registration = (fn, cb) ->
      if cb
        @@require-registration-cb = cb
      ->
        if window.user
          fn.apply window, arguments
        else
          Auth.show-register-dialog!
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
      @$.on \click '.dialog a.resend' @resend

      @$.on \click \.generate-password ~>
        # alphabet for a secure password
        az = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789$!@^&*(),[]-_<>'
        @@$ '#auth .password' .val([az.char-at Math.floor(Math.random! * az.length) for x to 32].join '').select!

      @$.on \click \.onclick-close-fancybox ->
        @@hide-info!
        if window.mutator is \privateSite # back to login dialog
          switch-and-focus 'on-dialog on-forgot on-register on-reset' \on-login '#auth input[name=login-email]'
        else
          $.fancybox.close!
      @$.on \click \.onclick-show-login ->
        @@hide-info!
        switch-and-focus 'on-forgot on-register on-reset' \on-login '#auth input[name=login-email]'
      @$.on \click \.onclick-show-forgot ->
        @@hide-info!
        switch-and-focus \on-error \on-forgot '#auth input[name=email]'
      @$.on \click \.onclick-show-choose ->
        @@hide-info!
        switch-and-focus \on-login \on-choose '#auth input[name=username]'
      @$.on \click \.onclick-show-register -> Auth.show-register-dialog!

      # catch esc key events on input boxes for Auth
      @$.on \keydown \input -> if it.which is 27 then $.fancybox.close!; false

    on-detach: !~>
      @@hide-info!

    # open window for 3rd party authentication
    open-oauth-window: (ev) ->
      url = $(this).attr \href
      window.open url, \popup, "width=980,height=650,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no"
      false

    # handler for login form
    login: (ev) ~>
      $form = $ ev.target
      u = $form.find 'input[name=login-email]'
      p = $form.find 'input[name=password]'
      s = $form.find 'input[type=submit]'
      params =
        username: u.val!
        password: p.val!
      s.attr \disabled \disabled
      cors.post "#{auth-domain}#{$form.attr(\action)}", params, (r) ~>
        if r.success
          <~ Auth.login-with-token
          if r.choose-name
            @after-login! if @after-login
            if Auth.require-login-cb
              Auth.require-login-cb!
              Auth.require-login-cb = null
            $ '.choose input:first' .val r.name
            switch-and-focus '', \on-choose, '.choose input:first'
          else
            $.fancybox.close!
            @after-login! if @after-login
            if Auth.require-login-cb
              Auth.require-login-cb!
              Auth.require-login-cb = null
            # reload page XXX I know its not ideal but the alternative is painful >.<
            if window.initial-mutant is \privateSite then window.location.reload!
        else
          if r.type is \unverified-user
            resend = """
            To resend your verification email, <a class="resend" data-email="#{r.email}">click here</a>.
            """
            @@show-info-dialog 'Please verify your account first.', resend, \on-login
          else
            $fancybox = $form.parents \.fancybox-wrap:first
            $fancybox.add-class \on-error
            show-tooltip $form.find(\.tooltip), 'Try again!' # display error
            shake-dialog $form, 100ms
            u.focus!
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
      s = $form.find 'input[type=submit]'
      s.attr \disabled \disabled
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          $form.find("input:text,input:password").remove-class(\validation-error).val ''
          switch-and-focus \on-register \on-dialog ''

          # autologin
          Auth.after-login!
          if Auth.require-registration-cb
            Auth.require-registration-cb!
            Auth.require-registration-cb = null
          Auth.show-info-dialog """
            Welcome to #siteName<br/>
            <small>Check your Email for a Welcome letter!</small>
          """

        else
          msgs = []
          r.errors?for-each (e) ->
            $e = $form.find("input[name=#{e.param}]")
            if $e.length then $e.add-class \validation-error .focus! # focus control
            msgs.push (e.msg or e)
          show-tooltip $form.find(\.tooltip), unique(msgs).join \<br> # display errors
          shake-dialog $form, 100ms
        s.remove-attr \disabled
      false

    # handler for form that asking for a password reset email
    forgot-password: (ev) ~>
      $form = $ ev.target
      s = $form.find 'input[type=submit]'
      s.attr \disabled \disabled
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          $ \#email .val '' # blank email
          Auth.show-info-dialog 'Check your inbox for reset link!', '', \on-forgot
        else
          $form.find \input:first .focus!
          msg = r.errors?0?name or r.errors?0 or 'Unable to find you'
          show-tooltip $form.find(\.tooltip), msg # display error
          shake-dialog $form, 100ms
        s.remove-attr \disabled
      false

    # handler for form for resetting a forgotten password
    reset-password: (ev) ~>
      $form = $ ev.target
      password = $form.find('input[name=password]').val!
      if password.match /^\s*$/
        show-tooltip $form.find(\.tooltip), "Password may not be blank"
        return false
      s = $form.find 'input[type=submit]'
      s.attr \disabled \disabled
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          $form.find('input').prop(\disabled, true)
          $form.find \#email .val '' # blank email
          show-tooltip $form.find(\.tooltip), "Password changed!"
          location.hash = ''
          $form.find('input[name=password]').val('')
          set-timeout ( ->
            switch-and-focus \on-reset, \on-login, '#auth .login input:first'
            show-tooltip $('#auth .login form .tooltip'), "Now log in!"
          ), 1500ms
        else
          show-tooltip $form.find(\.tooltip), "Choose a better password"
        s.remove-attr \disabled
      false

    # resend verification email
    resend: (ev) ~>
      email = $('.dialog a.resend').data \email
      r <- $.post '/auth/resend', { email }
      if r.success
        @@show-info-dialog 'Verification email sent again.', 'Please check your email.  It might be in your spam.'
      else
        @@show-info-dialog 'There was a problem sending the email', 'Please try again.'

    # this toggles the visibility of the password field in case people want to see
    # their password as they type it
    toggle-password: (ev) ~>
      e = $ ev.target
      p = e.prev-all '[name=password]'
      if p.attr(\type) is \password
        e.html \Hide
        p.attr \type \text
      else
        e.html \Show
        p.attr \type \password
      set-timeout (-> p.focus!), 10ms # focus!
      false

    # choose a username
    choose: (ev) ~>
      $form = $ ev.target
      s = $form.find 'input[type=submit]'
      s.attr \disabled \disabled
      $.post $form.attr(\action), $form.serialize!, (r) ~>
        if r.success
          if window.initial-mutant is \privateSite
            window.location.reload!
          else
            $.fancybox.close!
            v = $ \#username .val # blank username
            $ \#username .val ''
            @after-login!
            window.location.hash = ''
            storage.set \user, window.user <<< {name:v}
        else
          $form.find \input:first .focus!
          show-tooltip $form.find(\.tooltip), r.msg # display error
          shake-dialog $form, 100ms
        s.remove-attr \disabled
      false

    update-social-links: ->
      @$.find '.social a' .each (i, a) ->
        $a = $ a
        $a.attr \href, ($a.attr(\href).replace /\?origin=.*$/, "?origin=#{window.location.to-string!}")
