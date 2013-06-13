global.furl = require \./forum-urls.ls

global <<< require \./shared-helpers.ls

require! \../component/Paginator.ls

!function bench subject-name, subject-body
  bef = new Date
  subject-body!
  aft = new Date
  set-timeout(_, 1) ->
    dur = aft - bef
    console.log "benchmarked '#{subject-name}': took #{dur}ms"

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

load-css = []
load-css = (href) ->
  return if load-css[href] # guard
  $ \head .append($ '<link rel="stylesheet" type="text/css">' .attr(\href, href))
  load-css[href] = true

layout-on-personalize = (w, u) ->
  if u # guard
    set-online-user u.id
    # load editing scripts
    unless CKEDITOR?version        then $.get-script "#cache-url/local/editor/ckeditor.js"
    unless $!html5-uploader?length then $.get-script "#cache-url/local/jquery.html5uploader.js"
    unless $!Jcrop?length          then $.get-script "#cache-url/jcrop/js/jquery.Jcrop.min.js"
    # ...and css
    load-css "#cache-url/local/editor/skins/moono/editor.css"
    load-css "#cache-url/jcrop/css/jquery.Jcrop.min.css"
    # hash actions
    switch window.location.hash
    | \#choose   =>
      if is-email user?name
        show-login-dialog!
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

export homepage =
  static:
    (window, next) ->
      window.render-mutant \main_content \homepage
      # handle active forum background
#      window.$ \.bg-set .remove!
#      window.$ \.bg .each ->
#        e = window.$ this .add-class \bg-set .remove!
#        window.$ \body .prepend e
      layout-static window, \homepage
      next!
  on-personalize: (w, u, next) ->
    layout-on-personalize w, u
    next!
  on-load:
    (window, next) ->
      # reflow masonry content
      window.$ '.forum .container' .masonry(
        item-selector: \.post
        is-animated:   true
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
      catch
        # do nothing
      next!

export forum =
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

      window.marshal \activeForumId @active-forum-id
      window.marshal \activeThreadId @active-thread-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      window.marshal \prevPages @prev-pages

      #window.$ \.bg .remove! # XXX kill background (for now)

      layout-static window, \forum, @active-forum-id
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

      # add impression
      post-id = $('#main_content .post:first').data(\post-id)
      $.post "/resources/posts/#{post-id}/impression" if post-id

      # pager
      pager-init window

      # bring down first reply
      if user then $ \.onclick-append-reply-ui:first .click!

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
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      window.socket?emit \online-now
      next!
  on-personalize: (w, u, next) ->
    layout-on-personalize w, u
    next!
  on-unload:
    (window, next-mutant, next) ->
      try
        window.$ \#left_container .resizable(\destroy)
      catch
        # do nothing
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

export profile =
  static:
    (window, next) ->
      # conditionally render left_container
      if window.hints
        if not same-profile(window.hints)
          window.render-mutant \left_container \profile
      else
        window.render-mutant \left_container \profile

      window.render-mutant \main_content \posts-by-user
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      layout-static window, \profile
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
    if u # guard
      layout-on-personalize w, u

      path-parts = window.location.pathname.split '/'
      jcrop = void
      if path-parts.2 is u.name
        $ '.avatar img' .Jcrop aspect-ratio: 1.25, ->
          jcrop := this
        $ \.avatar .html5-uploader({
          name     : \avatar
          post-url : "/resources/users/#{u.id}/avatar"

          on-success: (x, y, json) ->
            r = JSON.parse json
            if typeof r is \object
              jcrop.destroy! if jcrop

              $ '.avatar img'
                .attr \src, "#{w.cache-url}/#{r.avatar}"
                .attr \style, ''
                .Jcrop aspect-ratio: 1.25, ->
                  jcrop := this
        })
    next!
  on-unload:
    (window, next-mutant, next) ->
      next!

export admin =
  static:
    (window, next) ->
      window.render-mutant \left_container \admin-nav
      window.render-mutant \main_content switch @action
      | \domains  => \admin-domains
      | \invites  => \admin-invites
      | \menu     => \admin-menu
      | otherwise => \admin-general
      layout-static window, \admin
      window.marshal \site @site
      next!
  on-unload:
    (window, next-mutant, next) ->
      if window.admin-expanded then $ \body .add-class \collapsed # restore
      next!
  on-load:
    (window, next) ->
      unless $!nested-sortable?length # load for /admin/menu
        $.get-script "#cache-url/local/jquery.mjs.nestedSortable.js"
      # expand left nav or not?
      $b = $ \body
      if window.admin-expanded = $b.has-class \collapsed
        $b.remove-class \collapsed
      $ 'form input:first' .focus!select!
      $ \.domain .trigger \change # fill-in authorization
      # no pager (for now)
      window.pages-count = 0
      pager-init window
      next!

join-search = (sock) ->
  console.log 'joining search notifier channel', window.searchopts
  sock.emit \search window.searchopts

end-search = ->
  socket.emit \search-end

export search =
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
            set-timeout(->
              console.log('overriding querystring due to forward/back button event')
            , 1)

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

        bench \layout-static ->
          layout-static window, \search

        window.component ||= {}

        # XXX
        # I know I am bruteforcing this right now but I don't wanna think of when stuff is
        # already around at the moment (the component can be reused in the future)
        window.component.search-paginator?detach!  # detach previous component

        pnum-to-href = (pnum) ->
          query =
            if pnum is void or parse-int(pnum) is 1
              rval = {} <<< @searchopts
              delete rval.page
              rval
            else
              {} <<< @searchopts <<< {page: pnum}

          if Object.keys(query).length
            \/search? + ["#k=#v" for k,v of query].join('&')
          else
            \/search

        window.component.search-paginator = new Paginator {locals: {step: 10, qty: @elres.total, active-page: @page}, pnum-to-href} window.$(\#search_paginator)

        next!
  on-initial:
    (window, next) ->
      # work around race condition! thx reactive ; )
      # chrome had different timing than FF
      # i.e. on-load was happening way before socket was
      # ready in chrome
      $R(join-search).bind-to window.r-socket
      next!
  on-mutate:
    (window, next) ->
      join-search(window.socket)
      next!
  on-load:
    (window, next) ->
      pager-init window
      next!
  on-unload:
    (window, next-mutant, next) ->
      end-search!
      delete window.searchopts # reset filter state so it doesn't come back to haunt us
      next!

export page =
  static:
    (window, next) ->
      window.replace-html window.$(\#left_container), ''
      window.replace-html window.$(\#main_content), @page.config.main_content
      layout-static window, \page
      next!
  on-load:
    (window, next) ->
      pager-init window
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
      next!

# vim:fdm=indent
