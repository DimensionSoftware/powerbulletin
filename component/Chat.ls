require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Chat extends Component
    component-name: \Chat
    @duration  = 300ms
    @easing    = \easeOutExpo
    @chats     = {}

    template: templates.Chat

    attach: ~>
      @$.on(\click, \.minimize, @minimize)
      @$.on(\click, \.close, @close)
      @$.on(\keydown, \textarea, @send-message)

    detach: !->
      @$.find \.minimize .off!
      @$.find \.close .off!

    key: ~>
      [me,others] = [@state.me!, @state.others!]
      "#{me}/#{others.join '/'}"

    message-node: (m) ~>
      $msg = @$.find('.body > .msg').clone!
      $msg.find('.text').html m.text
      $msg.find('.from-name').html m.from-name
      $msg

    send-message: (ev) ~>
      if ev.key-code is 13
        m =
          from-name: window.user.name
          text: @$.find('textarea').val!
        @add-message m

    add-message: (m) ~>
      $msg = @message-node m
      $messages = @$.find('.messages').append $msg
      $msg.show!
      $messages[0].scrollTop = $messages[0].scrollHeight
      @$.find \textarea .val ''

    load-more-messages: (offset, limit=8) ~>
      console.debug \load-more-messages, offset, limit
      r <- $.get '/resources/chats/messages', {}

    minimize: (state=true) ~>
      @$.add-class \minimized, state

    close: ~>
      Chat.stop(@key!)

Chat.start = ([me,...others]:users) ->
  key = users.join "/"
  if c = @chats[key]
    return c
  c = @chats[key] = new Chat locals: { me, others }, $('<div/>').hide!
  c.attach!
  #c.render!
  $cs = $('#chat_drawer .Chat')
  if $cs.length
    right = $cs.length * ($cs.first!width! + 8) + 8
    c.$.show!.transition({ right }, @duration, @easing)
    $('#chat_drawer').prepend(c.$)
  else
    right = 8
    c.$.show!.css({ right })
    $('#chat_drawer').prepend(c.$.show(@duration, @easing))
  c

Chat.stop = (key) ->
  c = @chats[key]
  if not c then return
  <~ c.$.fade-out @duration
  c.$.remove!
  @reorganize!
  delete @chats[key]

Chat.reorganize = ->
  $cs = $('#chat_drawer .Chat')
  width = $cs.first!width!
  n = $cs.length
  $cs.each (i,e) ->
    right = (n - i - 1) * (width + 8) + 8
    $(e).transition({ right }, @duration, @easing)

Chat.socket-init = (socket) ->
  socket.on \chat_message, (msg, cb) ->
    console.warn \hi, msg

