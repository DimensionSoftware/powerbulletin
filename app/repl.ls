global.async = require \async
global.data = global.d = require './data'
global.v = require './voltdb'

global <<< require \prelude-ls
global <<< require './helpers'

v.init!
