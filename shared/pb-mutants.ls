define = window?define or require(\amdefine) module
require, exports, module <- define

# needed here
require \jqueryWaypoints if window?

#XXX: this code is smelly, global-ness, bad
furl = require \../shared/forum-urls
purl = require \../shared/pb-urls

# only required if on client-side
if window?
  {set-imgs, align-ui, edit-post, fancybox-params, lazy-load-deserialize, lazy-load-fancybox, lazy-load-html5-uploader, lazy-load-nested-sortable, set-inline-editor, set-online-user, set-profile, set-wide, toggle-post} = require \../client/client-helpers
  ch = require \../client/client-helpers

{flip-background, is-editing, is-email, is-forum-homepage} = require \./shared-helpers
{last, sort-by} = require \prelude-ls

require! {
  \../component/SuperAdminUsers
  \../component/AdminUpgrade
  \../component/AdminMenu
  \../component/Paginator
  \../component/PhotoCropper
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
    if locals = first-klass-arg?locals
      c.locals locals
    c.reload!
  else # instantiate and register (locals are in first-klass-arg)
    # always instantiate using 'internal' dom by not passing a target at instantiation
    c = wc[name] = new klass(first-klass-arg)
  win.$(target).html('').append c.$ # render

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

# Common
set-background-onload = (w, background, duration=400ms, fx=\fade, cb=(->)) ->
  bg = w.$ \#forum_background
  bf = w.$ \#forum_background_buffer
  if background and bg.length and bf.length # double-buffer
    bf-img = bf.find \img
    bf-img
      ..attr \src, bf-img.data \src
      ..load ->
        bg.transition (if fx is \fade then {opacity:0} else {scale:1.5}), duration
        bf.transition opacity:1, duration, \easeOutExpo, ->
          # cleanup
          bg.remove!
          bf.attr \id, \forum_background
          cb!
  else if background # set bg
    ch.set-imgs!
  else if bg.length # no background passed in, so--reap both!
    bf.remove!
    bg.remove!
set-background-static = (w, cache-url, background) ->
  # wrap img for pseudo selectors
  img = (id) ~> "<div id='#id'><img data-src='#{cache-url}/sites/#{background}'></div>"
  bg  = w.$ \#forum_background
  if bg.length and background # use buffer
    w.$ \body .prepend (img \forum_background_buffer)
  else if background # first, so add
    w.$ \body .prepend (img \forum_background)
  if w.marshal then w.marshal \background, (background or void)

layout-static = (w, next-mutant, active-forum-id=-1) ->
  # XXX to be run last in mutant static
  # indicate current
  forum-class = if w.active-forum-id then " forum-#{w.active-forum-id}" else ''
  w.$ \html .attr(\class "#{next-mutant}#{forum-class}") # stylus
  if w.marshal then w.marshal \mutator, next-mutant      # js

  # handle active main menu
  fid = active-forum-id or w.active-forum-id
  w.$ 'header .menu' .find \.active # remove prev
    ..remove-class \active
    ..remove-class \hover
  w.$ "menu .row .forum-#fid" # add current
    ..add-class \active
    ..add-class \hover
  p = w.$ "menu .submenu .forum-#fid"
  if p.length # subform
    p.parent!add-class \active
    w.$(last p.parents \li) .children \.title # get parent, too
      ..add-class \active
      ..add-class \hover

  # handle backgrounds
  set-background-static w, @cache-url, @background

layout-on-personalize = (w, u) ->
  if u # guard
    set-online-user u.id
    set-profile u.photo

    # hash actions
    switch window.location.hash
    | \#choose   =>
      if is-email user?name
        Auth.show-login-dialog!
        switch-and-focus \on-login, \on-choose, '#auth input[name=username]'

# initialize pager
#pager-init = (w) ->
#  pager-opts =
#    current  : parse-int w.page
#    last     : parse-int w.pages-count
#    forum-id : parse-int w.active-forum-id
#  if w.pager
#    w.pager <<< pager-opts
#    w.pager.init!
#  else
#    w.pager = new w.Pager \#paginator pager-opts
#  w.pager.set-page(w.page, false) if w.page

@homepage =
  static:
    (window, next) ->
      window.render-mutant \main_content \homepage
      # handle active forum background
#      window.$ \.bg-set .remove!
#      window.$ \.bg .each ->
#        e = window.$ this .add-class \bg-set .remove!
#        window.$ \body .prepend e
      layout-static.call @, window, \homepage
      next!
  on-personalize: (w, u, next) ->
    layout-on-personalize w, u
    next!
  on-load:
    (window, next) ->
      try # reflow masonry content
        window.$ '.forum .container' .masonry(
          item-selector: \.post
          is-animated:   true
          animation-options:
            duration: 200ms
          is-fit-width:  true
          is-resizable:  true)

      # fill-in extra
      active = window.location.search.match(/order=(\w+)/)?1 or \recent
      window.jade.render $(\.extra:first).0, \order-control, active: active

      #{{{ Waypoints
      set-timeout (->
        # TODO use breadcrumb for sticky forum headers
        #$ = window.$
        #$ '.forum .header' .waypoint \sticky { offset: -70 }

        # forum switches
        $ \.forum .waypoint {
          offset  : \25%,
          handler : (direction) ->
            e   = $ this
            eid = e.attr \id

            # handle menu active
            id = if direction is \down then eid else
              $ "\##{eid}" .prev-all \.forum:first .attr \id
            return unless id # guard
            $ 'header .menu' .find \.active .remove-class \active # remove prev
            cur = $ 'header .menu'
              .find ".#{id.replace /_/ \-}"
              .add-class \active # ...and activate!

            # handle forum headers
            $ '.forum .stuck' .remove-class \stuck
            # TODO if direction is \up stick last forum

            flip-background window, cur, direction
        }

        reorder = __.debounce(( -> History.push-state {}, '', it), 100ms)
        window.current-order = false
        $ '#order li' .waypoint {
          context: \ul
          offset : 30px
          handler: (direction) ->
            e = $ this # figure active element
            if direction is \up
              e = e.prev!
            e = $ this unless e.length

            $ '#order li.active' .remove-class \active
            e .add-class \active # set!
            order = e.data \value
            path = "/?order=#order"
            if window.current-order then reorder path else window.current-order=order
        }), 100ms

      #window.awesome-scroll-to "forum_#{}"
      #}}}
      next!
  on-unload:
    (window, next-mutant, next) ->
      try
        window.$ '.forum .container' .masonry(\destroy)
        window.$ '.forum .header' .waypoint(\destroy)
        window.$ \.forum .waypoint(\destroy)
        window.$ '#order li' .waypoint(\destroy)
        window.$ \.bg .remove!
        window.$ $(\.extra:first) .html ''
      next!

# this function meant to be shared between static and on-initial
!function render-thread-paginator-component win, qty, step
  {templates} = require \../build/client-jade

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

@forum =
  static:
    (window, next) ->
      const prev-mutant = window.mutator

      # render main content
      window.render-mutant \main_content if is-editing(@furl.path) is true
        \post-new
      else if is-forum-homepage @furl.path
        \homepage
      else
        \posts

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

      #window.$ \.bg .remove! # XXX kill background (for now)

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
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"
      flip-background window, cur
      $ = window.$

      align-ui!

      $l = $ \#left_container
      $l.find \.active .remove-class \active # set active post
      $l.find ".thread[data-id='#{window.active-thread-id}']" .add-class \active

      # editing handler
      id = is-editing window.location.pathname
      if id then edit-post id, forum_id:window.active-forum-id
      # FIXME will do something smarter -k
      $ \body .on \click, toggle-post # expand & minimize drawer

      # add impression
      post-id = $('#main_content .post:first').data(\post-id)
      $.post "/resources/posts/#{post-id}/impression" if post-id

      # bring down first reply
      if user?
        e = $ \.onclick-append-reply-ui:first
          ..data \no-focus, true # not the neatest, needed to not steal ui focus
          ..click!
          ..data \no-focus, false

      # default surf-data (no refresh of left nav)
      window.surf-data = window.active-forum-id

      # handle forum background
      set-background-onload window, window.background

      next!
  on-initial:
    (window, next) ->
      # FIXME this is a race condition (on-static/on-load isn't finished when this runs)
      set-timeout (-> # scroll active thread on left nav into view
        threads = $ '#left_container .threads'
        offset  = -125px
        cur = threads.scroll-top!
        dst = Math.round($ '#left_container .threads > .active' .position!?top)
        if dst then threads.animate {scroll-top:cur+dst+offset}, 500ms, \easeOutExpo), 500ms

      render-thread-paginator-component window, window.t-qty, window.t-step
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      set-wide! # ensures correct style for width
      window.socket?emit \online-now
      next!
  on-personalize: (w, u, next) ->
    if u
      layout-on-personalize w, u
      # enable edit actions
      # - censor
      $ ".post[data-user-id=#{u.id}] .censor"
        .css \display \inline-block
      if u.rights?super
        $ \.censor .css \display \inline-block
      # - post editing
      set-inline-editor.call ch, u.id
    next!
  on-unload:
    (win, next-mutant, next) ->
      # cleanup
      $ \body .off \click
      try win.$ \#left_container .resizable(\destroy)
      unless next-mutant is \forum
        $ \#forum_background .remove!
        $ \#forum_background_buffer .remove!
        reset-paginator win
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
      #pager-init window
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      next!
  on-personalize: (w, u, next) ->
    <- lazy-load-html5-uploader

    photocropper-start = (ev) -> PhotoCropper.start!

    photocropper-enable = ->
      window.$(\#left_content).add-class \editable
      window.$(\body).on \click, '#left_content.editable .avatar', photocropper-start
      options =
        name: \avatar
        post-url: "/resources/users/#{window.user.id}/avatar"
        on-success: (xhr, file, r-json) ->
          r = JSON.parse r-json
          PhotoCropper.start mode: \crop, photo: r.url
      window.$('#left_content .avatar').html5-uploader options

    photocropper-disable = ->
      window.$(\#left_content).remove-class \editable
      window.$(\body).off \click, '#left_content.editable .avatar', photocropper-start

    if u # guard
      layout-on-personalize w, u
      profile-user-id = window.$('#left_content .profile').data \userId
      if profile-user-id is u.id
        photocropper-enable!
      else
        photocropper-disable!
    else
      photocropper-disable!
    next!
  on-unload:
    (window, next-mutant, next) ->
      reset-paginator window unless next-mutant is \forum
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
  | \domains  => try win.render-mutant \main_content, \admin-domains
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

      window.marshal \adminUsersLocals, ({} <<< @) if @action is \users
      render-admin-components @action, @site, window

      # these two vars have to be marshalled so the components have access
      # to them on-initial
      window.marshal \action @action
      window.marshal \site @site
      layout-static.call @, window, \admin
      next!
  on-personalize:
    (w, u, next) ->
      layout-on-personalize w, u
      next!
  on-unload:
    (window, next-mutant, next) ->
      if window.admin-expanded then $ \body .add-class \collapsed # restore
      next!
  on-load:
    (window, next) ->
      # expand left nav or not?
      $b = $ \body
      if window.admin-expanded = $b.has-class \collapsed
        $b.remove-class \collapsed
      $ 'form input:first' .focus!select!
      current-domain = (window.site.domains.filter (-> it.name is window.location.hostname))?0
      $('.domain select').val current-domain.id.to-string! if current-domain
      $ \.domain .trigger \change # fill-in authorization
      # no pager (for now)
      window.pages-count = 0
      #pager-init window
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
      scroll-to-top!
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
      next!
  on-load:
    (w, next) ->
      window.$new-hits = w.$('<div/>')  # reset new-hit div

      align-ui!
      #pager-init w

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
      window.replace-html window.$(\#left_container), ''
      window.replace-html window.$(\#main_content), @page.config.main_content
      window.marshal \activeForumId, @active-forum-id
      layout-static.call @, window, \page, @active-forum-id
      next!
  on-load:
    (window, next) ->
      #pager-init window
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      next!

# this mutant pre-empts any action for private sites where user is not logged in
# it means the site owner has specified that the site is private therefore we show a skeleton
# of the site and prompt for login (all sensitive details should be removed)
!function plax-bg window # background parallax
  window.$ \#forum_background .plaxify {y-range:15px,x-range:40px,invert:true}
!function rotate-backgrounds window, cache-url, backgrounds
  set-timeout (->
    # shuffle backgrounds & choose
    s = backgrounds |> sort-by (-> Math.random!)
    c = if (window.$ '#forum_background img' .attr \src).index-of(s.0.trim!) > -1 then s?1 else s?0
    # set choice in static & on-load
    set-background-static window, cache-url, c
    <- set-background-onload window, c, 2500ms, \scale
    plax-bg window
    rotate-backgrounds window, cache-url, backgrounds # again, and again...
  ), 9000ms
  #
@private-site =
  static: (window, next) ->
    window.$ \header .remove!
    window.$ \footer .remove!
    window.$ \#left_content .remove!
    window.$ \#main_content .remove!
    window.marshal \backgrounds, @backgrounds
    window.$ \body .add-class \parallax-viewport
    layout-static.call @, window, \privateSite
    next!
  on-load: (window, next) ->
    <~ lazy-load-fancybox

    # XXX: not sure why this fails the first time...
    # workaround ;(
    try
      <- require [\jqueryPlax]
    catch
      <- require [\jqueryPlax]


    # handle background
    rotate-backgrounds window, cache-url, window.backgrounds if window.backgrounds?length > 1

    #  show Auth dialog
    set-timeout (->
      # ensure login stays open
      window.fancybox-params ||= {}
      window.fancybox-params <<< {
        open-easing: \easeOutExpo
        open-speed:  1000ms
        close-btn:   false
        close-click: false
        modal:       true}
      <- Auth.show-login-dialog

      set-timeout (-> # XXX guarantee fancybox shows -- race condition & plax!
        plax = -> # parallax background & auth dialog
          $ \.fancybox-skin .plaxify {y-range:0,x-range:10px}
          plax-bg window
          $.plax.enable!
        unless $ \.fancybox-overlay:visible .length
          <- Auth.show-login-dialog
          plax!
        else
          plax!), 1200ms
      # remove initial hover state to dim if mouse is really hovered out
      #
      set-timeout (-> window.$ \.fancybox-skin .remove-class \hover), 3000ms
    ), 200ms

@moderation =
  static: (w, next) ->
    w.render-mutant \main_content \moderation
    layout-static.call @, w, \moderation
    next!
  on-load: (window, next) ->
    next!
@
# vim:fdm=indent
