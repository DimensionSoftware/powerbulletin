global <<< require \./pb-helpers
global.furl = require \./forum-urls

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
  w.$ 'menu .row' # add current
    .has ".forum-#fid"
    .find \.title
    .add-class \active
  w.$ "menu .submenu .forum-#fid" .parent!add-class \active

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
      window.$ \.bg-set .remove!
      window.$ \.bg .each -> window.$ this .add-class \bg-set .remove!prepend-to window.$ \body
      layout-static window, \homepage
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
      if prev-mutant != \forum or window.active-forum-id+'' != @surf-data
        window.render-mutant \left_container \nav # refresh on forum & mutant change

      window.marshal \activeForumId @active-forum-id
      window.marshal \activeThreadId @active-thread-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      window.marshal \prevPages @prev-pages

      window.$ \.bg .remove! # XXX kill background (for now)

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
      $l.find ".thread[data-id='#{active-thread-id}']" .add-class \active

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
    if u # guard
      set-online-user u.id
      $ ".post[data-user-id=#{u.id}] .edit"
        .css(\display \inline) # enable edit
    next!
  on-unload:
    (window, next-mutant, next) ->
      try
        window.$ \#left_container .resizable(\destroy)
      catch
        # do nothing
      next!

@profile =
  static:
    (window, next) ->
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
      set-online-user u.id
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

@admin =
  on-load:
    (window, next) ->
      $ 'form input:first' .focus!select!
      window.pages-count = 0
      pager-init window
  static:
    (window, next) ->
      window.render-mutant \left_container \admin-nav
      window.render-mutant \main_content switch @action
        | \authorization => \admin-authorization
        | otherwise      => \admin
      layout-static window, \admin
      next!

@search =
  static:
    (window, next) ->
      window.render-mutant \left_container \hits
      window.render-mutant \main_content \search

      unless History? #XXX: hack to only perform on serverside
        # represent state of filters in ui
        window.$(\#query).val @searchopts.q

      # TODO fill these in & paginate
      window.marshal \page @page
      window.marshal \pagesCount @pages-count

      layout-static window, \search
      next!
  on-load:
    (window, next) ->
      pager-init window
      next!
  on-unload:
    (window, next-mutant, next) ->
      $ \#query .val(unless next-mutant is \search
        '' # remove search query
      else
        History.get-state!data.searchopts.q) # restore
      next!
# vim:fdm=indent
