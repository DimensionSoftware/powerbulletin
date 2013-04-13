require! './indexer'

global <<< require \prelude-ls

err <- indexer.init!
if err then throw err
indexer.run!
