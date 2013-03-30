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
  console.log \thread thread
  #if thread.forum_id is active-forum-id
  console.log("ul.threads li[data-id=#{thread.id}] span.views")
  $("ul.threads li[data-id=#{thread.id}] span.views").html("#{thread.views} <i>views</i>")

socket.on \thread-create (thread, cb) ->
  insert-and-render window,  $('#left_content .threads li:first'), \_thread, thread:thread

socket.on \post-create (post, cb) ->
  console.log post
  window.post = post
  console.log "\#subpost_#{post.parent_id} .children"
  insert-and-render window, $("\#subpost_#{post.parent_id} + .children"), \_sub_post, sub-post:post

socket.on \debug, (message, cb) ->
  console.log \debug, message
