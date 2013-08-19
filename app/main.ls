global.env = process.env.NODE_ENV or 'development'

!function clean-require-cache
  for k,v of require.cache when (k.index-of(process.cwd! + '/build') is not -1) or (k.index-of(process.cwd! + "/app") is not -1) or (k.index-of(process.cwd! + "/component") is not -1)
    console.log('unrequiring: ' + k)
    delete require.cache[k]

var is-starting
var s
!function restart
  load = ->
    is-starting := true
    ServerApp = require \./ServerApp
    s := new ServerApp(process.argv.2 or parse-int(process.env.NODE_PORT) or 3000)
    s.start ->
      is-starting := false

  if is-starting
    console.warn "Still restarting ..."
  else
    if s
      s.stop ->
        clean-require-cache!
        load!
    else
      load!

process.on \SIGHUP, restart

restart!
# vim:fdm=marker
