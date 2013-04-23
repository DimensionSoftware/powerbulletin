global <<< require \./pb_helpers

# Common
layout-static = (w, mutator) ->
  w.last-mutator = w.mutator # save last
  # indicate current
  forum-class = if w.active-forum-id then " forum-#{w.active-forum-id}" else ''
  w.$ \html .attr(\class "#{mutator}#{forum-class}") # stylus
  w.marshal \mutator, mutator                        # js

  # handle active main menu
  #if mutator is not \homepage or not w.last-mutator
  console.log \menu + w.active-forum-id
  w.$ 'header .menu' .find \.active .remove-class \active # remove prev
  w.$ 'menu .row' # add current
    .has ".forum-#{w.active-forum-id}"
    .find '.title'
    .add-class \active
  w.$ "menu .submenu .forum-#{w.active-forum-id}" .parent!add-class \active

layout-on-load-resizable = (w) ->
  $ = window.$
  left-offset = 50px

  # handle main content
  $r = $ '#main_content .resizable'
  $p = $ \#paginator

  # handle left
  $l = $ \#left_content
  $l.resizable(
    min-width: 200px
    max-width: 450px
    resize: (e, ui) ->
      $l.toggle-class \wide ($l.width! > 300px)         # resize left nav
      $r.css 'padding-left' (ui.size.width+left-offset) # " resizable
      $p.css \left (ui.size.width)
      window.save-ui!)
  if $r.length
    $r.css \padding-left ($l.width!+left-offset) # snap

@homepage =
  static:
    (window, next) ->
      layout-static window, \homepage
      window.render-mutant \main_content \homepage

      # handle active forum background
      window.$ \.bg-set .remove!
      window.$ \.bg .each -> window.$ this .add-class \bg-set .remove!prepend-to window.$ \body
      next!
  on-initial:
    (window, next) ->
      active = window.location.search.match(/order=(\w+)/)?1 || \recent
      window.jade.render $(\.extra:first).0, \order_control, active: active
      next!
  on-load:
    (window, next) ->
      # reflow masonry content
      window.$ '.forum .container' .masonry(
        item-selector: \.post
        is-animated:   true
        is-fit-width:  true
        is-resizable:  true)
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
    (window, next) ->
      try
        window.$ '.forum .container' .masonry(\destroy)
        window.$ '.forum .header' .waypoint(\destroy)
        window.$ \.forum .waypoint(\destroy)
        window.$ '#order li' .waypoint(\destroy)
        window.$ \.bg .remove!
      catch
        # do nothing
      next!

@forum =
  static:
    (window, next) ->
      layout-static window, \forum
      window.render-mutant \main_content if is-editing @furl.path
        \post_new
      else if is-forum-homepage @furl.path
        \homepage
      else
        \posts
      window.render-mutant \left_content \nav unless window.last-mutator is \forum
      window.marshal \activeForumId @active-forum-id
      window.marshal \activePostId @active-post-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      window.marshal \prevPages @prev-pages
      window.$ \.bg .remove!
      next!
  on-load:
    (window, next) ->
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"
      flip-background window, cur
      $ = window.$

      align-breadcrumb!

      layout-on-load-resizable window

      $l = $ \#left_content
      $l.find \.active .remove-class \active  # set active post
      $l.find ".thread[data-id='#{active-post-id}']" .add-class \active

      # editing handler
      id = is-editing window.location.pathname
      if id then edit-post id, forum_id:window.active-forum-id

      # add impression
      post-id = $('#main_content .post:first').data('post-id')
      $.post "/resources/posts/#{post-id}/impression" if post-id

      render-sp = (sub-post) ->
        window.jade.templates._sub_post({window.cache_url, sub-post})

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
    (window, next) ->
      try
        window.$ \#left_content .resizable(\destroy)
      catch
        # do nothing
      next!

@profile =
  static:
    (window, next) ->
      layout-static window, \profile
      window.render-mutant \left_content \profile
      window.render-mutant \main_content \posts_by_user
      next!
  on-load:
    (window, next) ->
      layout-on-load-resizable window
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
  on-unload:
    (window, next) ->
      next!

@admin =
  static:
    (window, next) ->
      window.render-mutant \main_content \admin
      next!

@search =
  static:
    (window, next) ->
      layout-static window, \search
      window.render-mutant \left_content \hits
      window.render-mutant \main_content \search

      unless History? #XXX: hack to only perform on serverside
        # represent state of filters in ui
        window.$(\#query).val @searchopts.q

      next!

  on-load:
    (window, next) ->
      layout-on-load-resizable window
      next!

# vim:fdm=indent
