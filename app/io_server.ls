require! {
  sio: 'socket.io'
}
@init = (server) ->
  io = sio.listen server
  io.set 'log level', 1
  io.on 'connection', (socket) ->
    console.warn 'connected'
