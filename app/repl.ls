global.async = require \async
global.pg = require './postgres'
global.cl = console.log
global.cw = console.log

global <<< require \prelude-ls
global <<< require './helpers'

<- pg.init
global.procs = pg.procs # FIXME should work--right?
