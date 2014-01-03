define = window?define or require(\amdefine) module
require, exports, module <- define

require! { $R: \reactivejs }

# globals we want at beginning of application load (initial page load)
#@r-searchopts = $R.state window?searchopts
@r-searchopts = window?r-searchopts ?= $R.state window?searchopts
@r-socket = window?r-socket ?= $R.state!
@r-user = window?r-user ?= $R.state!
@r-t = window?r-t ?= $R.state!

@r-chats = window?r-chats ?= $R((socket, t) ->
  #console.warn \r-chats, socket, t
  #console.warn socket, !!socket
  return unless socket
  #console.warn \got-past-return
  set-timeout (->
    err, unread <- socket.emit \chat-unread
    #console.warn 'after socket.emit', err, unread
    for c in unread
      window.ChatPanel.add-conversation c, window.user
  ), 250ms
).bind-to @r-socket, @r-t

#console.trace \in-globals

@
# vim:fdm=marker
