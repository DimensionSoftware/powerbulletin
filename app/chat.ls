# client-side chat functionality

module.exports = class Chat

  (@$el, options) ->

    # handlers
    @$el.find \.close .click @close
    @$el.find \.minimize .click @minimize

  add-message: (text) ~>
    console.debug \add-message, text

  load-more-messages: (offset, limit=8) ~>
    console.debug \load-more-messages, offset, limit
    r <- $.get '/resources/chats/messages', {}

  minimize: (state=true) ~>
    console.debug \minimize
    @$el.add-class \minimized, state

  close: ~>
    console.debug \close
    @$el.remove()

Chat.start = ([me,...others]:users, cb) ->
  $c <- window.render-and-prepend window, $('#chat_drawer'), '_chat', {}
  c = new Chat $c, { me, others }
  cb null, c
