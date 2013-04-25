require! './search-notifier'

global <<< require \prelude-ls

err <- search-notifier.init 9999
if err then throw err
