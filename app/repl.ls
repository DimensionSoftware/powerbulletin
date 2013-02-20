global.async = require \async
global.pg = require './postgres'
global.h  = require './helpers'
global.cl = console.log
global.cw = console.warn

global <<< require \prelude-ls

global.db = -> pg.procs

pg.init!
