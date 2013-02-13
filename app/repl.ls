global.async = require \async
global.pg = require './postgres'
global.cl = console.log
global.cw = console.log

global <<< require \prelude-ls

global.db = -> pg.procs

pg.init!
