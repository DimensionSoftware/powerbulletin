require \./load-cvars

global.cl    = console.log
global.cw    = console.warn
global.async = require \async
global.auth  = require \./auth
global.c     = require \./cache
global.fsm   = require \../shared/fsm
global.furl  = require \../shared/forum-urls
global.surl  = require \../shared/sales-urls
global.pg    = require \./postgres
global.v     = require \./varnish
global.t     = require \../client/tasks
global.s     = require \./search

global.Presence = require \./presence

global <<< require \prelude-ls
global <<< require \./server-helpers
global <<< require \../shared/shared-helpers

global.el  = require \./elastic
global.elc = -> el.client
global.m   = require \./pb-models

global.io       = require(\socket.io-emitter)()
global.menu     = require \./menu

global.reload = (m) ->
  paths = require.resolve m
  if is-type \String, paths
    delete require.cache[paths]
  else
    paths.for-each (p) -> delete require.cache[p]
  require m

require! \./payments
require! \./validate-cc
global <<< {db: {}, pay: payments, vcc: validate-cc}

set-timeout (-> v.init!), 1000ms

err <- pg.init
if err then throw err
global.db <<< pg.procs

err <- m.init
if err then throw err
global.db <<< { [k,v] for k,v of global.m when k not in <[orm client driver]> }

err <- el.init
if err then throw err
