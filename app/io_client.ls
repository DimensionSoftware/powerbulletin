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

socket.on \post-create (post, cb) ->
  insert-and-render window,  $('#left_content .threads li:first'), \_thread, thread:post

socket.on \debug, (message, cb) ->
  console.log \debug, message
