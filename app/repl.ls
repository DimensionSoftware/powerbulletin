global.async = require \async
global.pg = require './postgres'
global.h  = require './helpers'
global.cl = console.log
global.cw = console.warn
global.v = require './varnish'
global.c = require './cache'
global.auth = require './auth'
global.fsm = require './fsm'

global <<< require \prelude-ls

global.db = -> pg.procs

pg.init!
set-timeout (-> v.init!), 1000
