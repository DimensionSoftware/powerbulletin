require! LiveScript

!function clean-require-cache
  for k,v of require.cache when (k.index-of(process.cwd! + '/build') is not -1) or (k.index-of(process.cwd! + "/app") is not -1) or (k.index-of(process.cwd! + "/component") is not -1)
    console.log('unrequiring: ' + k)
    delete require.cache[k]

var is-starting
var s
!function reload
  load = ->
    is-starting := true
    ServerApp = require \./ServerApp
    s := new ServerApp 3000
    s.start ->
      is-starting := false

  if is-starting
    console.warn "Can't reload yet! SLOW DOWN!"
  else
    if s
      s.stop ->
        clean-require-cache!
        load!
    else
      load!

process.on \SIGHUP, reload

reload!
# vim:fdm=marker
