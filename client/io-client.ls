define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \../component/ChatPanel
  \./globals
  mutants: \../shared/pb-mutants
  $R: \reactivejs
}

window.globals = globals

window.ChatPanel = ChatPanel

{render-and-append, add-commas} = require \../shared/shared-helpers
{lazy-load-socketio, set-online-user, storage, show-info, show-tooltip} = require \./client-helpers

window.lazy-load-socketio = lazy-load-socketio
window.show-info = show-info
window.show-tooltip = show-tooltip

####  main  ;,.. ___  _
init = -> # export socket to window + init
  if sock = window.socket = io?connect '', force-new: true
    init-with-socket sock
  sock
main = ->
  window.io <- require [ \socketio ]
  unless init!
    set-timeout (-> # static crashed or otherwise 50x'd--try again:
      window.io <- require [ \socketio ]
      init!) 3000ms
main!

force-reconnect = (s) ->
  io.connect '', force-new: true

const timeout = 1000ms
test-socket = (s, timeout, cb=(->)) ->
  err = true
  s.emit \ok, (e, r) ->
    #console.warn \after-emit-ok, err
    err := e
    cb e
  <- set-timeout _, timeout
  #console.warn \after-set-timeout, err
  if err then cb err

ready = (s) ->
  globals.r-socket s
  err, unread <- s.emit \chat-unread
  for c in unread
    window.ChatPanel.add-from-conversation c, window.user
  s.emit \online-now
  $ \html .remove-class \disconnected

# https://github.com/LearnBoost/socket.io/wiki/Exposed-events
# socket.on \event-name, (message, cb) ->
function init-with-socket s
  s.on \connect, ->
    #globals.r-socket s
    #console.log \connect
    if window.closed-duration-i
      clear-interval window.closed-duration-i
      window.closed-duration-i = null
      if window.closed-duration > 60s
        show-tooltip $('#warning'), "Reload For The Latest", 100000ms

  s.on \connect_failed ->
    #console.warn \connect_failed
    err <- test-socket s, timeout
    if err then force-reconnect s

  s.on \ready, ->
    #console.warn \ready
    err <- test-socket s, timeout
    if err
      force-reconnect s
    else
      ready s

  s.on \reconnect ->
    #console.log \reconnected
    err <- test-socket s, timeout
    #console.warn \reconnected-err, err
    if err then force-reconnect s

  s.on \reconnect_failed ->
    #console.warn \reconnect_failed
    err <- test-socket s, timeout
    if err then force-reconnect s

  s.on \disconnect, ->
    $ \html .add-class \disconnected
    #console.log \disconnect
    window.closed-duration = 0
    window.closed-duration-i = set-interval (-> window.closed-duration++), 1000ms

  s.on \logout, ->
    storage.del \user

  s.on \enter-site, (message, cb) ->
    #console.warn \enter-site, message
    set-online-user message?id

  s.on \leave-site, (message, cb) ->
    #console.warn \leave-site, message
    $ "[data-user-id=#{message.id}] .profile.photo" .remove-class \online

  s.on \menu-update, (menu, cb) ->
    $ \.MainMenu .html jade.templates.menu {menu}
    window.component.main-menu.detach!attach!

  s.on \thread-impression (thread, cb) ->
    if thread.forum_id is window.active-forum-id
      $ "\#left_container ul.threads li[data-id=#{thread.id}] span.views"
        .html "#{thread.views}<i>views</i>"

  s.on \thread-create (thread, cb) ->
    unless thread then return # guard
    if window.active-forum-id is thread?forum_id
      $ui.trigger \thread-create, thread

    # look for menu summary and increment thread count
    #console.log \thread-create, thread
    $forum = $(".MenuSummary .item-forum[data-db-id=#{thread.forum_id}]")
    return unless $forum.length
    $threads = $forum.find \.threads
    $threads.html(add-commas(1 + parse-int( $threads.text!replace /,/g, '' )))
    $last-post = $forum.find \.last-post
    $last-post.find \a.mutant.body .attr(href: thread.uri) .html(thread.title)
    $last-post.find \a.mutant.username .attr(href: "/user/thread.user_name") .html(thread.user_name)
    $date = $forum.find \span.date
    $date.data(time: thread.created_iso, title: thread.created_friendly) .html(thread.created_human)
    # also inc posts because new threads have 1 post
    $posts = $forum.find \.posts
    $posts.html(add-commas(1 + parse-int( $posts.text!replace /,/g, '' )))

  s.on \post-create (post, cb) ->
    # only real-time posts for users':
    # - currently active thread
    # - own posts on profile pages
    # TODO let user specify if they want real-time updates
    # - if they don't, inform them how many are new
    window.active-thread-id ||= -1
    if post.thread_id is window.active-thread-id or (post.user_id is user.id and window.mutator is \profile)
      return if $ "\#post_#{post.id}" .length # guard (exists)

      # update post count
      pc = $ "\#left_container ul.threads li[data-id=#{post.thread_id}] span.post-count"
      pc.html ("#{(parse-int pc.text!) + 1} <i>posts</i>")

      # & render new post
      commentable=window.commentable
      if commentable
        sel = "\#post_#{post.parent_id} ~ .children:first"
        unless $ sel .length # no immediate parent (eg. comment became a reply)
          commentable=false
          sel = "[data-thread-id=\"#{post.thread_id}\"]:last ~ .children:first"
      else
        sel = '.forum > .children > div'

      animate-in = (e) -> $ e .add-class \post-animate-in
      if post.user_id is user?id then post.is_comment=true # hide sig., etc... on our own posts
      render-and-append(
        window, (window.$ sel), \post, post:post, commentable:commentable, (new-post) ->
          if post.user_id is user?id # & scroll-to
            mutants.forum.on-personalize window, user, (->) # enable edit, etc...
            set-timeout (-> animate-in new-post), 250ms
            if window.mutator is \forum or window.mutator is \profile then awesome-scroll-to new-post, 300ms
          else
            animate-in new-post)

    # look for menu summary and increment post count
    #console.log \post-create
    $forum = $(".MenuSummary .item-forum[data-db-id=#{post.forum_id}]")
    return unless $forum.length
    $posts = $forum.find \.posts
    $posts.html(add-commas(1 + parse-int( $posts.text!replace /,/g, '' )))
    $last-post = $forum.find \.last-post
    # don't have enough data for this at the moment
    #$last-post.find \a.mutant.body .attr(href: thread.uri) .html(thread.title)
    #$last-post.find \a.mutant.username .attr(href: "/user/thread.user_name") .html(thread.user_name)
    $date = $forum.find \span.date
    $date.data(time: post.created_iso, title: post.created_friendly) .html(post.created_human)

  s.on \new-hit, (hit) ->
    hs = hit._source
    window.new-hits++
    window.$new-hits.prepend jade.templates.post({post: hs})

    # XXX: find out better place to declare these?
    # @beppusan, don't judge me for using onclick attributes ;)
    window.show-new-hits = ->
      <- window.awesome-scroll-to \#main_content, null
      $('#new_posts').html('').append(window.$new-hits).effect(\flash)
      return false # just in case its used in a click handler
    window.hide-new-hits = ->
      $('#new_posts').html('')
      return false # just in case its used in a click handler

    # FIXME move to jade, even if only for consistency and ajax instead of reloading
    suffix = if window.new-hits is 1 then '' else \s
    realtime-html = """
    <a href="#" onclick="showNewHits()">
      #{window.new-hits} new result#suffix
    </a>
    """

    # fills in top of search page with new hits total
    $ \#new_hit_count
      ..find \.count .html window.new-hits
      ..show!effect \highlight

    # fills in breadcrumb (selectors are poorly named ATM)
    $ \#new_hits .html realtime-html
    $ \#breadcrumb .slide-down 300ms

  # <profile-related updates>
  s.on \set-user, (user) ->
    storage.set \user, window.user = user           # local storage
    if window.r-user then window.r-user window.user # react
  s.on \new-profile-title, (user) ->
    $ "[data-user-id=#{user.id}] .user-title" .html user.title
  s.on \new-profile-photo, (user) -> # TODO smoothly load image
    $ "[data-user-id=#{user.id}]" .find('.profile img').attr \src, "#{cache-url}#{user.photo}"
    if window?user?id is user.id
      $ \#profile .attr \src, "#{cache-url}#{user.photo}"

  s.on \debug, (message, cb) ->
    console?log \debug, message

  s.on \chat-message, (message) ->
    ChatPanel.add-from-message message

  s.on \css-update, (message) ->
    $link = $ \#master-styl
    new-link = document.create-element \link
      ..type = \text/css
      ..rel  = \stylesheet
      ..href = $link.attr(\href).replace(/\?.*$/, ("?#{message.cache-buster}" || "?x"))
      ..id   = \master-styl
      ..onload = -> # cleanup
        $link.remove!
    $ \head .append new-link

# vim:fdm=indent
