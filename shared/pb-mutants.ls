define = window?define or require(\amdefine) module
require, exports, module <- define

#XXX: this code is smelly, global-ness, bad
furl = require \../shared/forum-urls

# only required if on client-side
if window?
  {align-breadcrumb, edit-post, lazy-load-deserialize, lazy-load-nested-sortable, set-inline-editor, set-online-user, set-profile, set-wide, toggle-post} = require \../client/client-helpers
  ch = require \../client/client-helpers

{flip-background, is-forum-homepage, is-editing} = require \./shared-helpers

require! {
  \../component/AdminUpgrade
  \../component/AdminMenu
  \../component/Paginator
  \../component/PhotoCropper
  \../client/globals
  __: lodash
}

!function bench subject-name, subject-body
  if process.env.NODE_ENV is \production
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
layout-static = (w, next-mutant, active-forum-id=-1) ->
  # XXX to be run last in mutant static
  # indicate current
  forum-class = if w.active-forum-id then " forum-#{w.active-forum-id}" else ''
  w.$ \html .attr(\class "#{next-mutant}#{forum-class}") # stylus
  w.marshal \mutator, next-mutant                        # js

  # handle active main menu
  fid = active-forum-id or w.active-forum-id
  w.$ 'header .menu' .find \.active .remove-class \active # remove prev
  # add current
  w.$ "menu .row .forum-#fid" .add-class \active
  p = w.$ "menu .submenu .forum-#fid"
  if p.length # subform
    p.parent!add-class \active
    w.$(last p.parents \li) .find \.title .add-class \active # get parent, too

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
pager-init = (w) ->
  pager-opts =
    current  : parse-int w.page
    last     : parse-int w.pages-count
    forum-id : parse-int w.active-forum-id
  if w.pager
    w.pager <<< pager-opts
    w.pager.init!
  else
    w.pager = new w.Pager \#paginator pager-opts
  w.pager.set-page(w.page, false) if w.page

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

      align-breadcrumb!

      $l = $ \#left_container
      $l.find \.active .remove-class \active # set active post
      $l.find ".thread[data-id='#{window.active-thread-id}']" .add-class \active

      # editing handler
      id = is-editing window.location.pathname
      if id then edit-post id, forum_id:window.active-forum-id
      $ \body .on \click, toggle-post # expand & minimize drawer

      # add impression
      post-id = $('#main_content .post:first').data(\post-id)
      $.post "/resources/posts/#{post-id}/impression" if post-id

      # pager
      pager-init window

      # bring down first reply
      if user
        set-timeout (-> $ \.onclick-append-reply-ui:first .click!), 300ms

      # default surf-data (no refresh of left nav)
      window.surf-data = window.active-forum-id
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
        .css \display \inline
      if u.rights?super
        $ \.censor .css \display \inline
      # - post editing
      set-inline-editor.call ch, u.id
    next!
  on-unload:
    (win, next-mutant, next) ->
      $ \body .off \click
      try win.$ \#left_container .resizable(\destroy)
      reset-paginator win unless next-mutant is \forum
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
      pager-init window
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
        on-success: (r) ->
          PhotoCropper.start mode: \crop
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
  | \menu     => render-component win, \#main_content, \admin-menu, AdminMenu, {locals: {site: site}}
  | \upgrade  => render-component win, \#main_content, \admin-upgrade, AdminUpgrade, {locals: {subscriptions: site.subscriptions}}
  | otherwise => try win.render-mutant \main_content, \admin-general

@admin =
  static:
    (window, next) ->
      window.render-mutant \left_container \admin-nav

      # set active nav
      window.$ '#left_container menu li' .remove-class \active
      window.$ "\#left_container menu .#{@action or \general}" .add-class \active

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
      $ \.domain .trigger \change # fill-in authorization
      # no pager (for now)
      window.pages-count = 0
      pager-init window
      <~ lazy-load-nested-sortable
      <~ lazy-load-deserialize
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
            $q.blur! # don't draw until we are blurred, this gave me back like 6ms!
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
      # work around race condition! thx reactive ; )
      # chrome had different timing than FF
      # i.e. on-load was happening way before socket was
      # ready in chrome
      $R(join-search).bind-to globals.r-socket
      next!
  on-mutate:
    (w, next) ->
      join-search(w.socket)
      next!
  on-load:
    (w, next) ->
      window.$new-hits = w.$('<div/>')  # reset new-hit div

      align-breadcrumb!
      pager-init w
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
      layout-static.call @, window, \page
      next!
  on-load:
    (window, next) ->
      pager-init window
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      next!

# this mutant pre-empts any action for private sites where user is not logged in
# it means the site owner has specified that the site is private therefore we show a skeleton
# of the site and prompt for login (all sensitive details should be removed)
@private-site =
  static: (window, next) ->
    #layout-static.call @ window, \privateSite
    window.$ \header .remove!
    window.$ \footer .remove!
    window.$ \#left_content .remove!
    window.$ \#main_content .remove!
    next!
  on-load: (window, next) ->
    # ensure login stays open
    window.fancybox-params <<< {
      close-btn:    false
      close-click:  false
      modal:        true}
    Auth.show-login-dialog! # show!
    next!

@
# vim:fdm=indent
