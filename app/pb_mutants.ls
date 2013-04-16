
global <<< require './pb_helpers'

# Common
layout-static = (w, mutator, forum-id=0) ->
  # indicate current
  forum-class = if forum-id then " forum-#{forum-id}" else ''
  w.$ \html .attr(\class "#{mutator}#{forum-class}") # stylus
  w.marshal \mutator, mutator                        # js

  # handle active forum background
  if mutator is \homepage and w.last-mutator is not \homepage
    w.$ '.bg-set' .remove!
    w.$ '.bg' .each -> w.$ this .add-class \bg-set .remove!prepend-to w.$ 'body'

  # handle active main menu
  if mutator is not \homepage or not w.last-mutator
    w.$ 'header .menu' .find '.active' .remove-class \active # remove prev
    w.$ 'menu .row' # add current
      .has ".forum-#{forum-id}"
      .find '.title'
      .add-class \active
    w.$ "menu .submenu .forum-#{forum-id}" .parent!add-class \active

  w.last-mutator = mutator # save last

layout-on-load = (w) ->
  $ = window.$
  left-offset = 50px

  # handle main content
  $r = $ '#main_content .resizable'

  # handle left
  $l = $ '#left_content'
  $l.resizable(
    min-width: 200px
    max-width: 450px
    resize: (e, ui) ->
      $l.toggle-class \wide ($l.width! > 300px)         # resize left nav
      $r.css 'padding-left' (ui.size.width+left-offset) # " resizable
      window.save-ui!)
  if $r.length
    $r.css 'padding-left' ($l.width!+left-offset) # snap

flip-background = (w, cur, direction='down') ->
  clear-timeout w.bg-anim if w.bg-anim
  last = w.$ '.bg.active'
  next = w.$ '#forum'+"_bg_#{cur.data \id}"
  next.css \display \block
  unless last.length
    next.add-class \active
  else
    w.bg-anim := set-timeout (->
      last.css \top if direction is \down then -300 else 300 # stage animation
      last.remove-class \active
      next.add-class \active # ... and switch!
      w.bg-anim = 0
    ), 100

@homepage =
  static:
    (window, next) ->
      window.render-mutant \main_content \homepage
      layout-static window, \homepage, @active-forum-id
      next!
  on-initial:
    (window, next) ->
      active = window.location.search.match(/order=(\w+)/)?1 || \recent
      window.jade.render $(\.extra:first)[0], \order_control, active: active
      next!
  on-load:
    (window, next) ->
      # reflow masonry content
      window.$ '.forum .container' .masonry(
        item-selector: '.post'
        is-animated:   true
        is-fit-width:  true
        is-resizable:  true)
      #{{{ Waypoints
      set-timeout (->
        # TODO use breadcrumb for sticky forum headers
        #$ = window.$
        #$ '.forum .header' .waypoint \sticky { offset: -70 }

        # forum switches
        $ '.forum' .waypoint {
          offset  : '25%',
          handler : (direction) ->
            e   = $ this
            eid = e.attr \id

            # handle menu active
            id = if direction is \down then eid else
              $ "\##{eid}" .prev-all '.forum:first' .attr \id
            return unless id # guard
            $ 'header .menu' .find '.active' .remove-class \active # remove prev
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
            order = e.data 'value'
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
        window.$ '.forum' .waypoint(\destroy)
        window.$ '#order li' .waypoint(\destroy)
      catch
        # do nothing
      next!
  on-personalize: (w, u, next) ->
    console.log w, u
    next!

@forum =
  static:
    (window, next) ->
      window.render-mutant \main_content (if is-editing(window.location.pathname) then \post_new else \posts)
      window.render-mutant \left_content \nav unless window.has-mutated-forum is @active-forum-id
      window.marshal \activeForumId @active-forum-id
      window.marshal \activePostId @active-post-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      window.marshal \prevPages @prev-pages
      layout-static window, \forum, @active-forum-id
      next!
  on-load:
    (window, next) ->
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"
      flip-background window, cur
      $ = window.$

      align-breadcrumb!

      layout-on-load window

      $l = $ '#left_content'
      $l.find '.active' .remove-class \active  # set active post
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
      window.has-mutated-forum = window.active-forum-id
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
        window.$ '#left_content' .resizable(\destroy)
      catch
        # do nothing
      next!

@profile =
  static:
    (window, next) ->
      window.render-mutant \left_content \profile
      window.render-mutant \main_content \posts_by_user
      layout-static window, \profile
      next!
  on-load:
    (window, next) ->
      layout-on-load window
      window.has-mutated-forum = true # force redraw
      next!
  on-mutate:
    (window, next) ->
      scroll-to-top!
  on-unload:
    (window, next) ->
      next!
  on-personalize:
    (w, u, next) ->
      next!

@admin =
  static:
    (window, next) ->
      window.render-mutant \main_content \admin
      next!

@search =
  static:
    (window, next) ->
      window.render-mutant \main_content \search
      layout-static window, \search, @active-forum-id

      unless History? #XXX: hack to only perform on serverside
        # represent state of filters in ui
        window.$('#query').val @searchopts.q

      next!

# vim:fdm=indent
