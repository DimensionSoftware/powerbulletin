require! { ch: './client-helpers.ls' }

<- ch.lazy-load-socketio

window.socket = io.connect!
window.r-socket = $R.state!

# https://github.com/LearnBoost/socket.io/wiki/Exposed-events
# socket.on \event-name, (message, cb) ->

socket.on \connect, ->
  r-socket socket # set reactive state
  #console.log \connected

socket.on \disconnect, ->
  #console.log \disconnected

socket.on \enter-site, (message, cb) ->
  console.warn \enter-site, message
  set-online-user message?id

socket.on \leave-site, (message, cb) ->
  console.warn \leave-site, message
  $ "[data-user-id=#{message.id}] .profile.photo" .remove-class \online

socket.on \thread-impression (thread, cb) ->
  if thread.forum_id is window.active-forum-id
    $ "\#left_container ul.threads li[data-id=#{thread.id}] span.views"
      .html "#{thread.views}<i>views</i>"

socket.on \thread-create (thread, cb) ->
  if window.active-forum-id is thread?forum_id
    $ui.trigger \thread-create, thread

socket.on \post-create (post, cb) ->
  # only real-time posts for users':
  # - currently active thread
  # - own posts on profile pages
  window.active-thread-id ||= -1
  if post.thread_id is window.active-thread-id or (post.user_id is user.id and mutator is \profile)
    return if $ "post_#{post.id}" .length # guard (exists)

    # update post count
    pc = $ "\#left_container ul.threads li[data-id=#{post.thread_id}] span.post-count"
    pc.html ("#{(parse-int pc.text!) + 1} <i>posts</i>")

    # & render new post
    sel = "\#post_#{post.parent_id} + .children"
    animate-in = (e) -> $ e .add-class \post-animate-in
    render-and-append(
      window, $(sel), \post, post:post, (new-post) ->
        if post.user_id is user?id # & scroll-to
          mutants.forum.on-personalize window, user, (->) # enable edit, etc...
          set-timeout (-> animate-in new-post), 250ms
          if mutator is \forum then awesome-scroll-to new-post, 300ms
        else
          animate-in new-post)

socket.on \new-hit, (hit) ->
  window.new-hits ||= 0
  window.new-hits++
  realtime-html = """
  <div><a href="#" onclick="window.location.reload()">#{window.new-hits} new search results!</a></div>
  last: <strong>#{hit._source.title || hit._source.body}</strong>
  """
  $('#new_hits').html realtime-html
  #console.log \new-hit, hit

socket.on \debug, (message, cb) ->
  console?log \debug, message

Chat.client-socket-init socket

# vim:fdm=indent
