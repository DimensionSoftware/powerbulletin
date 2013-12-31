define = window?define or require(\amdefine) module
require, exports, module <- define

require! { $R: \reactivejs }

# globals we want at beginning of application load (initial page load)
@r-searchopts = $R.state window?searchopts
@r-socket = $R.state!
@r-user = $R.state!
@r-t = $R.state!

@r-chats = window.r-chats  = $R((socket, t) ->
  console.warn \r-chats, socket, t
  return unless socket
  err, unread <- socket.emit \chat-unread
  for c in unread
    window.ChatPanel.add-conversation c, window.user
).bind-to @r-socket, @r-t

window <<< @

@
# vim:fdm=marker
