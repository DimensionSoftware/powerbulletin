global.async = require \async
global.pg = require './postgres'
global.h  = require './helpers'
global.cl = console.log
global.cw = console.warn
global.v = require './varnish'
global.c = require './cache'
global.auth = require './auth'
global.fsm = require './fsm'
global.furl = require './forum_urls'
global.sh = require './shared_helpers'
global.pbh = require './pb_helpers'

global <<< require \prelude-ls

global.db = -> pg.procs
global.el = require './elastic'
global.elc = -> el.client

pg.init!
el.init!
set-timeout (-> v.init!), 1000
