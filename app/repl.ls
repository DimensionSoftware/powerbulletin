global.cl    = console.log
global.cw    = console.warn
global.async = require \async
global.auth  = require \./auth
global.c     = require \./cache
global.fsm   = require \./fsm
global.furl  = require \./forum-urls
global.pg    = require \./postgres
global.v     = require \./varnish
global.t     = require \./tasks
global.s     = require \./search

global <<< require \prelude-ls
global <<< require \./helpers
global <<< require \./shared-helpers
global <<< require \./pb-helpers

global.db  = -> pg.procs
global.el  = require \./elastic
global.elc = -> el.client
global.m   = require \./pb-models

global.sioa     = require \socket.io-announce
global.announce = sioa.create-client!

set-timeout (-> v.init!), 1000ms
set-timeout (-> pg.procs <<< { [k,v] for k,v of global.m when k not in <[orm client driver]> }), 1000ms

err <- pg.init
if err then throw err
err <- m.init
if err then throw err
err <- el.init
if err then throw err
