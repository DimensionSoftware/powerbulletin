window.socket = io.connect!

# https://github.com/LearnBoost/socket.io/wiki/Exposed-events
# socket.on \event-name, (message, cb) ->

socket.on \connect, ->
  console.log \connected

socket.on \disconnect, ->
  console.log \disconnected

socket.on \enter-site, (message, cb) ->
  console.log \enter-site, message

socket.on \leave-site, (message, cb) ->
  console.log \leave-site, message

socket.on \debug, (message, cb) ->
  console.log \debug, message
