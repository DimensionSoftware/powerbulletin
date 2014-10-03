define = window?define or require(\amdefine) module
require, exports, module <- define

# needed here
require \jqueryWaypoints if window?

furl = require \../shared/forum-urls
purl = require \../shared/pb-urls

# only required if on client-side
if window?
  {show-tooltip, postdrawer, respond-resize, storage, switch-and-focus, set-imgs, align-ui, thread-mode, edit-post, fancybox-params, lazy-load-autosize, lazy-load-deserialize, lazy-load-fancybox, lazy-load-html5-uploader, lazy-load-nested-sortable, set-online-user, set-profile, set-wide, toggle-postdrawer, show-info} = require \../client/client-helpers
  ch = require \../client/client-helpers

{is-editing, is-email, is-forum-homepage} = require \./shared-helpers
{last, sort-by} = require \prelude-ls

require! {
  \../component/SuperAdminUsers
  \../component/AdminUpgrade
  \../component/AdminMenu
  \../component/Paginator
  \../component/PhotoCropper
  \../component/Editor
  \../component/Homepage
  \../component/Uploader
  \../client/globals
  __: lodash
  $R: reactivejs
}

!function bench subject-name, subject-body
  if env is \production
    subject-body! # run only
  else
    bef = new Date
    subject-body!
    aft = new Date
    set-timeout(_, 1) ->
      dur = aft - bef
      console.log "benchmarked '#{subject-name}': took #{dur}ms"

!function render-component win, target, name, klass, first-klass-arg
  wc = win.component ||= {}
  if c = wc[name] # already registered
    delete wc[name] # remove old

  # instantiate and register (locals are in first-klass-arg)
  # always instantiate using 'internal' dom by not passing a target at instantiation
  c = wc[name] = new klass(first-klass-arg)

  # unless auto-render is explicitly false, render
  unless first-klass-arg.auto-render is false then win.$(target).html('').append c.$

!function paginator-component w, locals, pnum-to-href
  wc = w.component ||= {}
  if wc.paginator
    wc.paginator.locals locals
    wc.paginator.pnum-to-href pnum-to-href
    wc.paginator.reload!
  else
    wc.paginator =
      new Paginator {locals, pnum-to-href} w.$(\#pb_paginator)

function parse-url url
  if document?
    a = document.create-element \a
    a.href = url
    {a.search, a.pathname}
  else
    p = require(\url).parse url
    {p.search, p.pathname}

function default-pnum-to-href-fun uri
  (pg) ->
    parsed = parse-url(uri)
    if pg > 1
      parsed.pathname + "?page=#pg"
    else
      parsed.pathname

{templates} = require \../build/client-jade

# Common
set-header-static = (w, cache-url, background) ->
  unless background then return # guard
  prepend = -> w.$ \header .prepend "<div id='header_background'><img data-src='#{cache-url}/sites/#{background}'></div>"
  w.$ \header .toggle-class \image, !!background
  unless w.$ \#header_background .length then prepend! # first, so add!
set-background-onload = (w, background, duration=400ms, fx=\fade, cb=(->)) ->
  bg = w.$ \#forum_background
  bf = w.$ \#forum_background_buffer
  bc = w.$ \#forum_background_color
  if background and bg.length and bf.length      # double-buffer replace!
    cur = bg.find \img .attr \src                # current visible background
    unless cur?match new RegExp "#{background}$" # bail if same ass passed in
      bf-img = bf.find \img
        ..attr \src, bf-img.data \src
        ..load ->
          bg.transition (if fx is \fade then {opacity:0} else {scale:1.5}), duration
          bf.transition opacity:1, duration, \easeOutExpo, ->
            # cleanup
            bg.remove!
            bf.attr \id, \forum_background
            cb!
    bc.remove!
  else if background # set bg
    bc.remove!
    set-imgs!
  else if bg.length # no background passed in, so--reap bg + buffer & use color!
    bf.remove!
    bg.remove!
set-background-static = (w, cache-url, background) ->
  # wrap img for pseudo selectors
  img = (id) ~> "<div id='#id' style='background-image: url(#{cache-url}/sites/#{background})'></div>"
  bg  = w.$ \#forum_background
  if bg.length and background # use buffer
    w.$ \body .prepend (img \forum_background_buffer)
  else if background # first, so add
    w.$ \body .prepend (img \forum_background)
  else # use solid background color
    unless w.$ \#forum_background_color .length # no dups
      w.$ \body .prepend '<div id="forum_background_color"></div>'
  if w.marshal then w.marshal \background, (background or void)

layout-static = (w, next-mutant, active-forum-id=-1) ->
  # XXX to be run last in mutant static
  # indicate current
  forum-class = if w.active-forum-id then " forum-#{w.active-forum-id}" else ''
  w.$ \html .attr(\class "#{next-mutant}#{forum-class}") # stylus
  if w.marshal
    w.marshal \mutator, next-mutant # js
    w.marshal \adminChat, @admin-chat
    w.marshal \fixedHeader, @fixed-header

  # handle active main menu
  fid = active-forum-id or w.active-forum-id
  w.$ 'header .menu' .find \.active # remove prev
    ..remove-class \active
    ..remove-class \hover
  w.$ "menu .row .forum-#fid" # add current
    ..add-class \active
  p = w.$ "menu .submenu .forum-#fid"
  if p.length # subform
    p.parent!add-class \active
    w.$(last p.parents \li) .children \.title # get parent, too
      ..add-class \active
      ..add-class \hover

  # handle backgrounds
  # XXX forum backgrounds are only allowed on private sites
  # other mutants get a solid (tint) color that's defaulted gray
  set-header-static w, @cache-url, @header
  if next-mutant in <[forum profile search moderation privateSite]> # background color for these
    set-background-static w, @cache-url, (if next-mutant is \privateSite then @private-background)

layout-on-personalize = (w, u) ->
  if u # guard
    set-online-user u.id
    set-profile u.photo

    # hash actions
    switch w.location.hash
    | \#choose   =>
      if is-email user?name
        w.Auth.show-login-dialog!
        w.switch-and-focus \on-login, \on-choose, '#auth input[name=username]'

@homepage =
  static:
    (window, next) ->
      render-component window, \#main_content, \Homepage, Homepage, {-auto-attach, locals:@}
      window.marshal locals:@
      layout-static.call @, window, \homepage
      next!
  on-personalize: (w, u, next) ->
    layout-on-personalize w, u
    next!
  on-mutate: 
    (window, next) ->
      snap-to-top!
      $ \body .remove-class \footer-show
  on-load:
    (window, next) ->
      render-component window, \#main_content, \Homepage, Homepage, {-auto-render}
      time-updater!
      next!
  on-unload:
    (window, next-mutant, next) ->
      next!

# this function meant to be shared between static and on-initial
!function render-thread-paginator-component win, qty, step

  on-page = (page) ->
    # XXX: this is sort of a stopgap I know we need pretty ui
    # TODO: This is stub, we need actual real views
    # !!!!!!!!!!!!!!!!!!!!!!!!!! ^_^
    $.get "/resources/threads/#{window.active-forum-id}" {page} (top-threads, status) ->
      container = win.$('#left_container .scrollable')
      container.html templates.__threads({top-threads})
      #container.html "#{JSON.stringify threads}"
  locals = {qty, step, active-page: 1}
  render-component win, \#thread-paginator, \threadPaginator, Paginator, {locals, on-page}

!function remove-backgrounds w
  w.$ \#forum_background .remove!
  w.$ \#forum_background_color .remove!
  w.$ \#forum_background_buffer .remove!

@forum =
  static:
    (window, next) ->
      const prev-mutant = window.mutator

      # render main content
      unless @fixed-header
        if is-forum-homepage @furl.path # show tall header only on forum homepages
          window.$ \body .remove-class \scrolled
        else # begin with smaller "scrolled" header
          window.$ \body .add-class \scrolled

      if is-editing(@furl.path) is true
        window.render-mutant \main_content, \post-new
      else if is-forum-homepage @furl.path
        render-component window, \#main_content, \Homepage, Homepage, {-auto-attach, locals:@}
      else
        window.render-mutant \main_content, \posts

      # add locked class to body (@item is the current forum)
      is-locked = if @item?form
        !!if @post
          (@post.is_locked or @item.form?locked)
        else
          @item.form?locked
      else
        false # default
      window.$ \body .toggle-class \locked, is-locked

      not-commentable = not @item?form?comments
      window.$ \body .toggle-class \no-comments, not-commentable

      # render left content
      if @top-threads
        window.render-mutant \left_container \nav # refresh on forum & mutant change
        render-thread-paginator-component window, @t-qty, @t-step
        window.marshal \tQty, @t-qty
        window.marshal \tStep, @t-step

      window.marshal \activeForumId @active-forum-id
      window.marshal \activeThreadId @active-thread-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      window.marshal \prevPages @prev-pages
      window.marshal \social @social
      window.marshal \commentable @commentable
      window.marshal \replyTo @post?title
      window.marshal \replyBy @post?user_name
      # XXX facilitate content by allowing everyone to upload (for now)
      #window.marshal \allowUploads @item?form?uploads
      window.marshal \allowUploads true

      hh = @item?form?hide-homepage
      window.marshal \hideHomepage hh
      if hh then window.$ \#main_content .add-class \transparent

      do ~>
        if not @post then return
        wc = window.component ||= {}

        locals =
          step: @limit
          qty: @qty
          active-page: @page

        pnum-to-href = mk-post-pnum-to-href @post.uri

        paginator-component window, locals, pnum-to-href

      layout-static.call @, window, \forum, @active-forum-id
      next!
  on-load:
    (window, next) ->
      $   = window.$
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"

      align-ui!

      $l = $ \#left_container
      $l.find \.active .remove-class \active # set active post
      $l.find ".thread[data-id='#{window.active-thread-id}']" .add-class \active
      $l.on \click.thread \.thread (ev) ->
        $ ev.current-target .add-class \active      # mutant is slow, update immediately
        ($ ev.target .find \.mutant).trigger \click # mutate
      respond-resize!

      # editing handler
      id = is-editing window.location.pathname
      if id then edit-post id, forum_id:window.active-forum-id
      #window.$ \body .on \click.pd, toggle-postdrawer # expand & minimize drawer
      if user then postdrawer!set-draft!
      $ \html .add-class \new # for stylus

      # add impression
      post-id = $('#main_content .post:first').data(\post-id)
      $.post "/resources/posts/#{post-id}/impression" if post-id

      # default surf-data (no refresh of left nav)
      window.surf-data = window.active-forum-id

      # handle forum background
      set-background-onload window, window.background

      <- lazy-load-autosize

      #{{{ refresh share links
      if window.social
        # load share links for fb, google & twitter
        # https://developers.facebook.com/docs/plugins/share-button/
        ``
        (function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=240716139417739";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
        ``
        # https://about.twitter.com/resources/buttons#tweet
        ``
        (function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}})(document, 'script', 'twitter-wjs');
        ``
        # https://developers.google.com/+/web/share/
        ``
        (function() {
          var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
          po.src = 'https://apis.google.com/js/platform.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
        })();
        ``
        # for mutations
        #try gapi.plusone.go!
        try FB.XFBML.parse!
        try twttr.widgets.load!
      #}}}

      if is-forum-homepage window.location.pathname
        if window.hide-homepage # handle homepage or not
          $ '.threads .thread:first .mutant' .click!
        else
          window.$ \#main_content .remove-class \transparent # fade content in

        homepage-postdrawer = ->
          thread-mode true
          postdrawer!
            ..clear!
            ..editor?focus!
          <- set-timeout _, 100ms # FIXME this is janky, need to simplify states, hard w/ mutant
          $ \#action_wrapper .remove-class 'reply edit' # clear title
        # intercept for thread-mode
        $ \.onclick-footer-toggle .on \click.homepage (ev) ->
          ev.prevent-default!
          <- set-timeout _, 200ms
          homepage-postdrawer!
        homepage-postdrawer!
        # render homepage
        render-component window, \#main_content, \Homepage, Homepage, {-auto-render}
      else
        window.$ \#main_content .remove-class \transparent # fade content in
      time-updater!
      next!
  on-initial:
    (window, next) ->
      if window.social
        # share links for fb, google & twitter
        # https://developers.facebook.com/docs/plugins/share-button/
        ``
        (function(d, s, id) {
          var js, fjs = d.getElementsByTagName(s)[0];
          if (d.getElementById(id)) return;
          js = d.createElement(s); js.id = id;
          js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=240716139417739";
          fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
        ``
        # https://about.twitter.com/resources/buttons#tweet
        ``
        (function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}})(document, 'script', 'twitter-wjs');
        ``
      # scroll active thread on left nav into view
      threads = $ '#left_container .scrollable'
      offset  = -125px
      cur = threads.scroll-top!
      dst = Math.round($ '#left_container .threads > .active' .position!?top)
      if dst then threads.scroll-top cur+dst+offset

      # FIXME move arrow on scroll
      #orig = $ '#left_container .active' .offset!top
      #$ '#left_container .scrollable' .on \scroll.Forum ->
      #  e   = $ '#left_container .active'
      #  cur = e.offset!top
      #e.find \.arrow .transition {y:cur - orig}, 0

      render-thread-paginator-component window, window.t-qty, window.t-step
      next!
  on-mutate:
    (window, next) ->
      set-wide! # ensures correct style for width
      window.socket?emit \online-now
      snap-to-top!
      next!
  on-personalize: (w, u, next) ->
    w.r-user u
    if u
      layout-on-personalize w, u
      # enable edit actions
      $ ".post[data-user-id=#{u.id}] .censor" .css \display \inline-block     # censor
      $ ".post[data-user-id=#{u.id}] [data-edit]" .css \display \inline-block # post edit
      if u.rights?super then $ \.censor .css \display \inline-block
      # remove body.locked if super
      # XXX shouldn't make the ui jump
      if u.rights?super or u.sys_rights?super then w.$ \body .remove-class \locked
    next!
  on-unload:
    (w, next-mutant, next) ->
      # cleanup
      w.$ \.onclick-footer-toggle .off \click.homepage
      w.$ \body .off \click
      w.$ \#main_content .add-class \transparent
      #w.$ \body .off \click.pd
      #$ '#left_container .scrollable' .off \scroll.Forum
      try w.$ \#left_container .resizable(\destroy)
      if w.user then postdrawer!
        ..reload!
        ..save-draft!
        # back to Reply mode
        ..clear!
        ..edit-mode!
        thread-mode false
      unless next-mutant is \forum_background
        remove-backgrounds w
        reset-paginator w
      next!

same-profile = (hints) ->
  [l, c] = [hints.last, hints.current]
  if l.mutator is null
    return false
  [p1, p2] = [l.pathname.split('/'), c.pathname.split('/')]
  if p1[1] is \user and p2[1] is \user
    if p1[2] is p2[2]
      return p1[2]
  false

@profile =
  static:
    (window, next) ->
      # conditionally render left_container
      if window.hints
        if not same-profile(window.hints)
          window.render-mutant \left_container \profile
      else
        window.render-mutant \left_container \profile

      window.render-mutant \main_content \posts-by-user
      window.marshal \step @step
      window.marshal \qty @qty
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      do ~>
        locals =
          step: @limit
          qty: @qty
          active-page: @page

        pnum-to-href = mk-post-pnum-to-href "/user/#{@profile.name}"
        window.marshal \uri, @uri
        paginator-component window, locals, pnum-to-href
      layout-static.call @, window, \profile
      next!
  on-load:
    (window, next) ->
      # forgot password delegate
      #window.$ \body .on \click.pd, toggle-postdrawer # expand & minimize drawer
      profile-user-id = $('#left_content .profile').data \userId
      unless profile-user-id is user?id
        enable-chat!

      if user?name is user?email # enable username switch only if haven't set
        window.$ \.onclick-show-choose .show!
        window.$ \body .on \click \.onclick-show-choose ->
          Auth.show-choose-dialog!

      window.$ \body .on \click \.onclick-show-forgot ->
        <- Auth.show-login-dialog
        show-tooltip ($ '#auth .forgot .tooltip'), 'We\'ll Send A Single-Use, Secure Link'
        <- set-timeout _, 150ms # yield
        switch-and-focus \on-error \on-forgot '#auth input[name=email]', false
      <- lazy-load-autosize
      next!
  on-mutate:
    (window, next) ->
      snap-to-top!
      next!
  on-personalize: (w, u, next) ->
    <- lazy-load-html5-uploader

    photocropper-start = (ev) -> PhotoCropper.start!

    change-sig-enable = ->
      w.$ \.onclick-change-sig .on \click ->
        <~ lazy-load-fancybox
        e = w.component.editor = new Editor {locals:
          id:   \sig
          url:  "/resources/aliases/#{w.user.id}"
          body: (storage.get \user)?sig or u?sig
          auto-save: true}
        w.$.fancybox e.$, {after-close:-> w.user <<< sig:e.body!; storage.set \user, w.user; e.detach!} <<< fancybox-params # set sig & cleanup

    change-title-enable = ->
      last = user?title or \first # default
      e = w.$ \#change_title
      e.on \click -> false # interception
      e.on \keypress (ev) -> if (ev.key-code or ev.which) is 13 then false else true
      e.on \keyup __.debounce (-> # watch & save title
        cur = e.val!
        unless last then last := \first
        if last isnt cur # save!
          w.$.ajax {
            type: \PUT
            url:  "/resources/aliases/#{w.user.id}",
            data:
              config:
                title: cur
            success: ->
              last := cur
              show-tooltip (w.$ \.change-tooltip), \Saved!, 3000ms
          }), 800ms
    photocropper-enable = ->
      w.$ \#left_content .add-class \editable
      w.$ \body .on \click, '#left_content.editable .avatar', photocropper-start
      options =
        name: \avatar
        post-url: "/resources/users/#{w.user.id}/avatar"
        on-success: (xhr, file, r-json) ->
          r = JSON.parse r-json
          PhotoCropper.start mode: \crop, photo: r.url
      w.$('#left_content .avatar').html5-uploader options

    photocropper-disable = ->
      w.$(\#left_content).remove-class \editable
      w.$(\body).off \click, '#left_content.editable .avatar', photocropper-start

    if u # guard
      layout-on-personalize w, u
      w.$ \#change_title .val u?title # most current (cache blow)
      profile-user-id = w.$('#left_content .profile').data \userId
      if profile-user-id is u.id
        change-sig-enable!
        change-title-enable!
        photocropper-enable!
        window.$ \#change_title .focus!
        # show info tips?
        k = "#{u.id}-profile" # key
        unless storage.get k or u?title
          show-info 0,
            [\.left-content, 'Spice up your posts with a Profile Photo, Title &amp; Signature!', true]
          storage.set k, true
      else
        enable-chat!
        photocropper-disable!
    else
      photocropper-disable!
    next!
  on-unload:
    (window, next-mutant, next) ->
      # cleanup/unbind
      window.$ \body .off \click \.onclick-show-forgot
      window.$ \body .off \click.pd
      window.$ \#change_title .off!
      window.$ \.onclick-change-sig .off!
      reset-paginator window
      next!
  on-initial:
    (window, next) ->
      do ~>
        locals =
          step: window.step
          qty: window.qty
          active-page: window.page
        name = window.location.pathname.split('/')[2]
        pnum-to-href = mk-post-pnum-to-href "/user/#name"
        paginator-component window, locals, pnum-to-href
      next!

# this function meant to be shared between static and on-initial
!function render-admin-components action, site, win
  switch action
  | \domains  => try win.render-mutant \main_content, \admin-general
  | \invites  => try win.render-mutant \main_content, \admin-invites
  | \users    => render-component win, \#main_content, \admin-users, SuperAdminUsers, {locals: {} <<< win.admin-users-locals <<< {purl.gen}}
  | \menu     => render-component win, \#main_content, \admin-menu, AdminMenu, {locals: {site:site}}
  | \upgrade  => render-component win, \#main_content, \admin-upgrade, AdminUpgrade, {locals: {subscriptions: site.subscriptions}}
  | otherwise => try win.render-mutant \main_content, \admin-general

@admin =
  static:
    (window, next) ->
      window.render-mutant \left_container \admin-nav

      # set active nav
      window.$ '#left_container menu li' .remove-class \active
      window.$ "\#left_container menu .#{@action or \general}" .add-class \active

      if @action is \users
        @.cols.splice 3, 1                # prune photo col
        @.rows.for-each -> it.splice 3, 1 # ...and assoc. row
        window.marshal \adminUsersLocals, {} <<< @
      render-admin-components @action, @site, window

      # these two vars have to be marshalled so the components have access
      # to them on-initial
      window.marshal \action @action
      window.marshal \site @site
      layout-static.call @, window, \admin
      remove-backgrounds window
      next!
  on-personalize:
    (w, u, next) ->
      layout-on-personalize w, u
      next!
  on-unload:
    (window, next-mutant, next) ->
      if window.admin-expanded then $ \body .add-class \collapsed # restore
      window.component.logo-uploader?detach!
      window.component.header-uploader?detach!
      window.component.background-uploader?detach!
      $ \.onsave-hide .off!
      $ 'html.admin .theme .onclick-close' .off!
      next!
  on-load:
    (window, next) ->
      # expand left nav or not?
      $b = $ \body
      if window.admin-expanded = $b.has-class \collapsed
        $b.remove-class \collapsed
      $ 'form input:first' .focus!select!
      window.set-admin-ui!
      current-domain = (window.site.domains.filter (-> it.name is window.location.hostname))?0
      if current-domain then $ \#domain .val current-domain.id.to-string!
      $ \#domain .trigger \change # fill-in authorization
      if window.location.to-string!match \domains
        $ \#domains .attr \checked, true
        $ 'label[for="domains"]' .effect \highlight
        awesome-scroll-to \#domains

      $ 'html.admin #domain' .trigger \change # setup domains

      # hue color selection
      update-preview = ->
        $ '.preview .s-dark-chat'
          .css {["#{k}filter", "hue-rotate(#{$ \#sprite_hue .val!})"] for k in ['', '-moz-', '-webkit-', '-o-']}
      $ \#sprite_hue .on \keyup update-preview  # live hue preview
      $ '.hue-selector span' .on \click -> # update hue on click
        v = $ @ .attr \data-hue
        $ \#sprite_hue .val (v * 3deg + \deg)
        update-preview!

      # init-html5-uploader
      logo    = window.site.config.logo
      site-id = window.site.id
      window.component.logo-uploader = new Uploader {
        locals:
          name:      \logo
          preview:   if logo then logo else void
          post-url:  "/resources/sites/#site-id/logo"
          on-delete: ~> # remove logo
            $ 'header .logo'
              ..remove-class \custom-logo
              ..find \img .attr \src, "#cache-url/images/transparent-1px.gif"
          on-success: (xhr, file, r) ~> # set logo
            $ 'header .logo'
              ..add-class \custom-logo
              ..find \img .attr \src, "#cache-url/sites/#{r.logo}"
      }, \#logo_uploader
      header = window.site.config.header
      window.component.header-uploader = new Uploader {
        locals:
          name:      \header
          preview:   if header then header else void
          post-url:  "/resources/sites/#site-id/header"
          on-delete: ~> # remove header
            $ '#header_background img' .attr \src, "#cache-url/images/transparent-1px.gif"
            $ \header.header .remove-class \image
          on-success: (xhr, file, r) ~>
            $ '#header_background img' .attr \src, "#cache-url/sites/#{r.header}"
            $ \header.header .add-class \image
      }, \#header_uploader
      private-background = window.site.config.private-background
      window.component.background-uploader = new Uploader {
        locals:
          name:      \background
          preview:   if private-background then private-background else void
          post-url:  "/resources/sites/#site-id/private-background"
          on-delete: ~> # remove background
            $ '#forum_background img' .attr \src, "#cache-url/images/transparent-1px.gif"
          on-success: (xhr, file, r) ~>
            $ '#forum_background img' .attr \src, "#cache-url/sites/#{r.private-background}"
      }, \#background_uploader

      <~ requirejs [\jqueryIris] # live color preview
      hide = ->
        $ '.color-picker .iris-picker' .hide!
        $ \.hue-selector .hide!
        $ 'html.admin .theme .onclick-close' .hide!
      $ \.onsave-hide .on \click, hide
      add-color = (defaults, color) ->
        if color then defaults.unshift color
        defaults
      $ \#sprite_hue .on \focus -> hide!; $ \.hue-selector .show!; $ 'html.admin .theme .onclick-close' .show!
      $ \#theme
        .iris({
          width: 167px
          target: '.theme .color-picker'
          palettes: add-color <[ #4ccfea #cc8888 #a2ef2e #ff8c00 #f24e4e ]>, site.config.color-theme?theme_color
          change: (ev, ui) ->
            $(ev.target).next!css background-color: ui.color.to-string!
        })
        .focus((ev) -> 
          hide!
          $ 'html.admin .theme .onclick-close' .show!
          $(ev.current-target).iris \show)
      $ \#colored_text
        .iris({
          width: 167px
          target: '.theme .color-picker'
          palettes: add-color <[ #222222 #555555 #dddddd #ffffff ]>, site.config.color-theme?colored_text
          change: (ev, ui) ->
            $(ev.target).next!css background-color: ui.color.to-string!
        })
        .focus((ev) -> 
          hide!
          $ 'html.admin .theme .onclick-close' .show!
          $(ev.current-target).iris \show)
      $ 'html.admin .theme .onclick-close' .click (ev) -> hide!; $ ev.current-target .hide!

      # no pager (for now)
      window.pages-count = 0
      <~ lazy-load-html5-uploader
      <~ lazy-load-fancybox
      <~ lazy-load-nested-sortable
      next!
  on-initial:
    (win, next) ->
      render-admin-components win.action, win.site, win
      next!
  on-mutate:
    (window, next) ->
      snap-to-top!
      next!

join-search = (sock) ->
  #console.log 'joining search notifier channel', window.searchopts
  sock.emit \search window.searchopts

reset-paginator = (w) ->
  # cleanup paginator on exit
  $ \#pb_paginator .hide!
  if w.component?paginator
    w.component.paginator
      ..local \qty 0
      ..reload!

end-search = (w) ->
  reset-paginator w
  socket.emit \search-end

mk-search-pnum-to-href = (searchopts) ->
  (pnum) ->
    query =
      if pnum is void or parse-int(pnum) is 1
        rval = {} <<< searchopts
        delete rval.page
        rval
      else
        {} <<< searchopts <<< {page: pnum}

    delete query.site_id # don't put this in url, it's implied by domain, for uber pretty-ness

    if Object.keys(query).length
      \/search? + ["#k=#v" for k,v of query].join('&')
    else
      \/search

mk-post-pnum-to-href = (post-uri) ->
  (pnum) -> if pnum > 1 then "#{post-uri}/page/#{pnum}" else post-uri

@search =
  static:
    prepare:
      (window, next) ->
        params = @
        # fresh state
        after = window.after-prepare = []

        # TODO fill these in & paginate
        window.marshal \page @page
        window.marshal \pagesCount @pages-count
        window.marshal \searchopts @searchopts
        window.marshal \newHits 0 # reset new-hit count

        # only render left side on first time to search
        # filters can be dom-touched, no need to re-insert innerhtml, as that is awkward
        unless window.hints?last?mutator is \search
          do ->
            window.replace-html(window.$(\#left_container), '<div id="search_filters"></div><div id="search_facets"></div>')
            filters-html = window.render \search-filters # get html rendered
            $t = window.$('#search_filters')
            after.push ->
              bench \search-filters -> window.replace-html($t, filters-html)

        # facets are updated on every single searchopts change
        do ->
          html = window.render \search-facets # get html rendered
          $t = window.$('#search_facets')
          after.push ->
            bench \search-facets ->
              window.replace-html $t, html

        do ->
          html = window.render \search # get html rendered
          $t = window.$('#main_content')
          after.push ->
            bench \search-content -> window.replace-html($t, html)

        # represent state of filters in ui
        $q = window.$(\#query)
        q-el = $q.0
        q = @searchopts.q

        if History?
          # only perform on client-side

          if @statechange-was-user
            # only perform when back/forward button is pressed
            after.push ->
              bench \query-string-update ->
                q-el.value = q
        else
          # only perform on server-side

          after.push ->
            bench \query-string-update ->
              $q.val q

        if History?
          # only perform on client-side
          if document.active-element is q-el
            # XXX 6ms is a huge win but it causes the ui to flicker
            # let's put this back when we have the need for speed  -k
            #$q.blur! # don't draw until we are blurred, this gave me back like 6ms!
            after.push ->
              bench \re-focus ->
                set-timeout(_, 1) ->
                  $q.focus! # re-focus
        next!
    draw:
      (window, next) ->
        # state prepared by prepare phase
        after = window.after-prepare

        #XXX: might be able to turn this into a pattern...
        for f in after
          f! # memoized functions should close over pure data.. no cbs should be needed

        # initial filter state
        bench \filter-state ~>
          window.$('#search_filters [name=forum_id]').val @searchopts.forum_id
          window.$('#search_filters [name=within]').val @searchopts.within

        do ~>
          wc = window.component ||= {}

          locals =
            step: 10
            qty: @elres.total
            active-page: @page

          pnum-to-href = mk-search-pnum-to-href @searchopts

          paginator-component window, locals, pnum-to-href

        bench \layout-static ~>
          layout-static.call @, window, \search
        next!
  on-initial:
    (w, next) ->
      next!
  on-mutate:
    (w, next) ->
      snap-to-top!
      next!
  on-load:
    (w, next) ->
      window.$new-hits = w.$('<div/>')  # reset new-hit div

      align-ui!

      # avoid stacking up search join requests
      # only pay attention to last one
      clear-timeout window.join-search-timeout

      # I do despise this, but it does work in most cases
      # XXX: hack... figure out a better way???!!?
      # we need to know when socket.io is connected
      window.join-search-timeout = set-timeout (->
        join-search(w.socket)
      ), 3000

      next!
  on-unload:
    (w, next-mutant, next) ->
      end-search(w)
      delete w.searchopts # reset filter state so it doesn't come back to haunt us
      next!

@page =
  static:
    (window, next) ->
      window.$ \body .toggle-class \minimized, !!(@page.config.content-only or @page.config.offer-content-only)
      if @page.config.dialog is \offer # render jade offer template
        @page.cache-url = @cache-url
        @page.site-name = @site-name
        @page.social    = @social
        window.marshal \social, @social
        window.replace-html window.$(\#main_content), (templates.offer @page)
      else
        window.replace-html window.$(\#left_container), ''
        window.replace-html window.$(\#main_content), @page.config.main_content
      window.marshal \dialog, @page.config.dialog
      window.marshal \activeForumId, @active-forum-id
      window.marshal \offerContentOnly, @page.config.offer-content-only
      window.marshal \newsletter, @newsletter
      window.marshal \newsletterMsg, @newsletterMsg
      window.marshal \newsletterAction, @newsletterAction
      remove-backgrounds window
      layout-static.call @, window, \page, @active-forum-id
      next!
  on-load:
    (window, next) ->
      $ document .scroll-top 0
      if user
        $ \#newsletter .remove-class \shown # always remove
      else
        $ \#newsletter .toggle-class \shown, window.newsletter is \checked # bring out newsletter?
      $ \body .add-class \loaded

      # show newsletter & confirmation once for guests
      if !user and window.dialog is \offer
        const k = "newsletter-#siteId"
        storage.del k # reset
        window.onbeforeunload = (ev) -> # confirm close for guests
          unless storage.has k # prompt once
            storage.set k, true
            set-timeout Auth.show-newsletter-dialog, 10ms
            ev = ev or window.event # ie & ff
            const msg = '''


            You\'ll be missing out on all the latest!
            Prefer our newsletter?


            '''
            if ev then ev.return-value = msg
            msg

      #{{{ refresh share links
      if window.social
        set-timeout (->
          # load share links for fb, google & twitter
          # https://developers.facebook.com/docs/plugins/share-button/
          ``
          (function(d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) return;
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=240716139417739";
            fjs.parentNode.insertBefore(js, fjs);
          }(document, 'script', 'facebook-jssdk'));
          ``
          # https://about.twitter.com/resources/buttons#tweet
          ``
          (function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}})(document, 'script', 'twitter-wjs');
          ``
          # https://developers.google.com/+/web/share/
          ``
          (function() {
            var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
            po.src = 'https://apis.google.com/js/platform.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
          })();
          ``
          # for mutations
          #try gapi.plusone.go!
          try FB.XFBML.parse!
          try twttr.widgets.load!), 1234ms # yield
      #}}}
      next!
  on-unload:
    (window, next-mutant, next) ->
      $ \body .remove-class \loaded
      window.onbeforeunload = void # clear
      unless next-mutant is \page
        $ \#newsletter .remove-class \shown
        $ \body .remove-class \minimized
      next!
  on-mutate:
    (window, next) ->
      snap-to-top!
      next!
  on-personalize:
    (w, u, next) ->
      layout-on-personalize w, u
      next!

# this mutant pre-empts any action for private sites where user is not logged in
# it means the site owner has specified that the site is private therefore we show a skeleton
# of the site and prompt for login (all sensitive details should be removed)
!function rotate-backgrounds window, cache-url, backgrounds
  set-timeout (->
    # shuffle backgrounds & choose
    s = backgrounds |> sort-by (-> Math.random!)
    c = if (window.$ '#forum_background img' .attr \src)?index-of(s.0.trim!) > -1 then s?1 else s?0
    # set choice in static & on-load
    set-background-static window, cache-url, c
    <- set-background-onload window, c, 2500ms, \scale
    rotate-backgrounds window, cache-url, backgrounds # again, and again...
  ), 9000ms
  #
@private-site =
  static: (window, next) ->
    window.$ \header .remove!
    window.$ \footer .remove!
    window.$ \#menu .remove!
    window.$ \#left_content .remove!
    window.$ \#main_content .remove!
    window.$ \body .add-class \oval # fancybox theme
    window.$ '[name="robots"]' .attr \content, 'noindex, nofollow'
    window.marshal \background, @private-background
    layout-static.call @, window, \privateSite
    next!
  on-load: (window, next) ->
    <~ lazy-load-fancybox

    window.fancybox-params ||= {}
    window.fancybox-params <<< {
      open-easing: \easeOutExpo
      open-speed:  1000ms
      close-btn:   false
      close-click: false
      modal:       true}

    # show Auth dialog
    <- Auth.show-login-dialog
    set-timeout (-> # XXX guarantee fancybox shows
      unless $ \.fancybox-overlay:visible .length
        <- Auth.show-login-dialog), 100ms

    # handle background
    rotate-backgrounds window, cache-url, window.backgrounds if window.backgrounds?length > 1
    <- require ["#cache-url/local/jquery.waitforimages.min.js"]
    bg = $ \#forum_background # fade-in background after loaded
      ..wait-for-images -> bg.add-class \visible

    fb  = window.$ \.fancybox-skin
    dim = -> fb.remove-class \hover
    fr  = set-timeout dim, 6000ms # dim if mouse hovers out
    opaque = -> # opaque on key press, and re-dim
      clear-timeout fr
      fb.add-class \hover
      fr := set-timeout dim, 4000ms
    fb.on \click, opaque
    window.$ 'input[placeholder]' .on \keydown, opaque

@moderation =
  static: (w, next) ->
    w.render-mutant \main_content \moderation
    layout-static.call @, w, \moderation
    next!
  on-personalize: (w, u, next) ->
    if u.rights?super
      $ \.uncensor .css \display \inline-block
    layout-on-personalize w, u
    next!
  on-mutate: (w, next) ->
    snap-to-top!
    next!
  on-load: (window, next) ->
    next!


function snap-to-top
  if window.mutator isnt \forum then $ \body .remove-class \scrolled
  if window.scroll-to then window.scroll-to 0, 0
  <~ set-timeout _, 80ms # yield to browser
  if window.scroll-to then window.scroll-to 0, 0

function enable-chat
  if window.admin-chat
    if window?user?rights?super then window.$ \.onclick-chat .remove-class \hidden
  else
    window.$ \.onclick-chat .remove-class \hidden

@
# vim:fdm=indent
