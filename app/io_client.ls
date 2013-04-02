window.socket = io.connect!

# https://github.com/LearnBoost/socket.io/wiki/Exposed-events
# socket.on \event-name, (message, cb) ->

socket.on \connect, ->
  console.log \connected

socket.on \disconnect, ->
  console.log \disconnected

socket.on \enter-site, (message, cb) ->
  $ "[data-user-id=#{message.id}] .profile.photo" .add-class \online

socket.on \leave-site, (message, cb) ->
  $ "[data-user-id=#{message.id}] .profile.photo" .remove-class \online

socket.on \thread-impression (thread, cb) ->
  if thread.forum_id is active-forum-id
    $("\#left_content ul.threads li[data-id=#{thread.id}] span.views").html("#{thread.views} <i>views</i>")

socket.on \thread-create (thread, cb) ->
  if active-forum-id is thread.forum_id
    <- render-and-prepend window,  $('#left_content .threads'), \_thread, thread:thread
    $ '#left_content .threads div.fadein li' .unwrap!

socket.on \post-create (post, cb) ->
  if post.thread_id is active-post-id
    # update post count
    pc = $ "\#left_content ul.threads li[data-id=#{post.thread_id}] span.post-count"
    pc.html ("#{(parse-int pc.text!) + 1} <i>posts</i>")

    # & render new post
    sel =
      if post.parent_id is post.thread_id
        "\#post_#{post.parent_id} + .children [data-infinity-pageid]"
      else
        "\#subpost_#{post.parent_id} + .children"
    render-and-append(
      window, $(sel), \_sub_post, sub-post:post, (e) ->
        $e = $ e
        $e .effect(\highlight 1000ms \easeOutExpo)
        if post.user_id is user.id # & scroll-to
          set-timeout (-> awesome-scroll-to e), 100ms)

socket.on \debug, (message, cb) ->
  console.log \debug, message
