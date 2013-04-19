global.cl    = console.log
global.cw    = console.warn
global.async = require \async
global.auth  = require \./auth
global.c     = require \./cache
global.fsm   = require \./fsm
global.furl  = require \./forum_urls
global.pg    = require \./postgres
global.v     = require \./varnish

global <<< require \prelude-ls
global <<< require \./helpers
global <<< require \./shared_helpers
global <<< require \./pb_helpers

global.db  = -> pg.procs
global.el  = require \./elastic
global.elc = -> el.client

pg.init!
el.init!
set-timeout (-> v.init!), 1000ms
