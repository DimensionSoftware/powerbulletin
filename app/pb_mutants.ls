
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

align-breadcrumb = ->
  set-timeout (-> $ '.breadcrumb.stuck' .css(\left, $('#left_content').width! + 20)), 100

@homepage =
  static:
    (window, next) ->
      window.render-mutant 'main_content' \homepage
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
        # sticky forum headers
        $ = window.$
        $ '.forum .header' .waypoint \sticky { offset: -70 }

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

@forum-new =
  on-load:
    (window, next) ->
      console.log \new
      next!

@forum =
  static:
    (window, next) ->
      window.render-mutant 'left_content' \nav unless window.has-mutated-forum is @active-forum-id
      window.render-mutant 'main_content' \posts
      window.marshal \activeForumId @active-forum-id
      window.marshal \activePostId @active-post-id
      window.marshal \page @page
      window.marshal \lv null # clear list view, so it can be re-initialized
      window.marshal \infinityStop false # clear flag to stop infinity at end of pages
      layout-static window, \forum, @active-forum-id
      next!
  on-load:
    (window, next) ->
      cur = window.$ "header .menu .forum-#{window.active-forum-id}"
      flip-background window, cur
      $ = window.$

      # handle main content
      $ '.forum .breadcrumb' .waypoint(\sticky, { handler:align-breadcrumb, offset:-70 })
      $f = $ '#main_content.container .forum'

      # handle left
      $l = $ '#left_content'
      $l.resizable(
        min-width: 200
        max-width: 450
        resize: (e, ui) ->
          align-breadcrumb!
          $l.toggle-class \narrow (ui.size.width < 300)
          $f.css('padding-left', ui.size.width); window.save-ui!)
      $f.css('padding-left', ($l.width! + 20))

      # editing handler
      edit-post is-editing!

      # add impression
      post-id = $('#main_content .post:first').data('post-id')
      $.post "/resources/posts/#{post-id}/impression" if post-id

      next!
  on-mutate:
    (window, next) ->
      # handle scrolling
      unless scroll-to-edit!
        window.scroll-to-top!
      window.has-mutated-forum = window.active-forum-id
      next!
  on-personalize: (w, u, next) ->
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
