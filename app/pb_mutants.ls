
global <<< require './pb_helpers'

# Common
layout-static = (w, mutator, forum-id=0) ->
  # indicate current
  forum-class = if forum-id then " forum-#{forum-id}" else ''
  w.$ \html .attr(\class "#{mutator}#{forum-class}") # stylus
  w.marshal \mutator, mutator                        # js
  # handle active forum background
  w.$ '.bg-set' .remove!
  w.$ '.bg' .each -> w.$ this .add-class \bg-set .remove!prepend-to w.$ 'body' # position behind
  # handle active main menu
  w.$ 'header .menu' .find '.active' .remove-class \active # remove prev
  w.$ 'menu .row' # add current
    .has ".forum-#{forum-id}"
    .find '.title'
    .add-class \active
  w.$ "menu .submenu .forum-#{forum-id}" .parent().add-class \active

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
        }), 100

      #window.awesome-scroll-to "forum_#{}"
      #}}}
      next!
  on-unload:
    (window, next) ->
      try
        window.$ '.forum .container' .masonry(\destroy)
        window.$ '.forum .header' .waypoint(\destroy)
        window.$ '.forum' .waypoint(\destroy)
      catch
        # do nothing
      next!
  on-personalize: (w, u, next) ->
    console.log w, u
    next!

@forum =
  static:
    (window, next) ->
      window.render-mutant \main_content (if @uri.match(/\/new/) then \post_new else \posts)
      window.render-mutant \left_content \nav unless window.has-mutated-forum is @active-forum-id
      window.marshal \activeForumId @active-forum-id
      window.marshal \activePostId @active-post-id
      window.marshal \page @page
      window.marshal \pagesCount @pages-count
      layout-static window, \forum, @active-forum-id
      next!
  on-load:
    (window, next) ->
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"
      flip-background window, cur
      $ = window.$

      # handle main content
      align-breadcrumb!
      $f = $ '#main_content.container .forum'

      # handle left
      $l = $ '#left_content'
      size-nav = (w) -> $l.toggle-class \wide (w > 300px)
      $l.resizable(
        min-width: 200px
        max-width: 450px
        resize: (e, ui) ->
          size-nav $l.width!
          $f.css 'padding-left' ui.size.width; window.save-ui!)
      $f.css 'padding-left' ($l.width! + 20px) # snap
      $l.find '.active' .remove-class \active  # set active post
      $l.find ".thread[data-id='#{active-post-id}']" .add-class \active

      # editing handler
      edit-post is-editing!

      # add impression
      post-id = $('#main_content .post:first').data('post-id')
      $.post "/resources/posts/#{post-id}/impression" if post-id

      # handle scrolling
      scroll-to-edit!

      render-sp = (sub-post) ->
        window.jade.templates._sub_post({window.cache_url, sub-post})

      lazy = ->
        $(this).find('[data-page]:not(.page-loaded)').each ->
          $pg = $(this)
          $pg.add-class \page-loaded
          $pg.css height:\auto
          page = $pg.data(\page)

          sub-posts <- $.getJSON "/resources/posts/#{window.active-post-id}/sub-posts", {page}
          for sub-post in sub-posts
            $pg.append render-sp(sub-post)

        personalize = ->
          socket.emit \online-now # update presence info
          window.mutants[window.mutator].on-personalize window, window.user, (->)
        set-timeout personalize, 500

      # initialize ListView
      $children = $('#main_content > .forum > .children')
      html = $children.html!
      $children.html ''
      window.lv = new infinity.ListView($children, {lazy})
      window.lv.append(html) # lift static html into the listview

      next!
  on-mutate:
    (window, next) ->
      # handle scrolling
      unless scroll-to-edit!
        window.scroll-to-top!
      window.has-mutated-forum = window.active-forum-id
      window.socket?emit \online-now
      next!
  on-personalize: (w, u, next) ->
    if u # guard
      $ ".subpost[data-user-id=#{u.id}] .edit, .post[data-user-id=#{u.id}] .edit"
        .css(\display \inline) # enable edit
    next!
  on-unload:
    (window, next) ->
      try
        window.$ '.forum .breadcrumb' .waypoint(\destroy)
        window.$ '#left_content' .resizable(\destroy)
      catch
        # do nothing
      next!

@profile =
  static:
    (window, next) ->
      window.render-mutant 'main_content' \profile
      layout-static window, \profile
      next!
  on-load:
    (window, next) ->
      next!
  on-unload:
    (window, next) ->
      next!
  on-personalize:
    (w, u, next) ->
      next!

@search =
  static:
    (window, next) ->
      next!
  on-load:
    (window, next) ->
      next!
  on-initial:
    (window, next) ->
      # set initial state
      next!
  on-mutate:
    (window, next) ->
      next!

@admin =
  static:
    (window, next) ->
      next!

# vim:fdm=indent
