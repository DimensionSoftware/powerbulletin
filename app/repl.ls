global.async = require \async
global.data = global.d = require './data'
global.v = require './voltdb'
global.pg = require './postgres'

global <<< require \prelude-ls
global <<< require './helpers'

v.init '127.0.0.1'
pg.init!
