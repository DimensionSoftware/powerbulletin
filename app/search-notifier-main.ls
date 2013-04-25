require! './search-notifier'

global <<< require \prelude-ls

err <- search-notifier.init!
if err then throw err
search-notifier.run!
