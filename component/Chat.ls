require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Chat extends Component
    @duration  = 300ms
    @easing    = \easeOutExpo
    @chats     = {}

    template: templates.Chat

    attach: ~>
      @$top.on(\click, \.minimize, @minimize)
      @$top.on(\click, \.close, @close)

    detach: !->
      @$top.find \.minimize .off!
      @$top.find \.close .off!

    key: ~>
      {me,others} = @state!
      "#{me}/#{others.join '/'}"

    message-node: (m) ~>
      $msg = @$top.find('.body > .msg').clone!
      $msg.find('.text').html m.text
      $msg.find('.from-name').html m.from-name
      $msg

    add-message: (m) ~>
      $msg = @message-node m
      $messages = @$top.find('.messages').append $msg
      $msg.show!
      $messages[0].scrollTop = $messages[0].scrollHeight

    load-more-messages: (offset, limit=8) ~>
      console.debug \load-more-messages, offset, limit
      r <- $.get '/resources/chats/messages', {}

    minimize: (state=true) ~>
      @$top.add-class \minimized, state

    close: ~>
      Chat.stop(@key!)

Chat.start = ([me,...others]:users) ->
  key = users.join "/"
  if c = @chats[key]
    return c
  c = @chats[key] = new Chat { me, others }, $('<div/>').hide!
  c.render!
  c.put!
  $cs = $('#chat_drawer .Chat')
  if $cs.length
    right = $cs.length * ($cs.first!width! + 8) + 8
    c.$top.show!.find('.Chat').transition({ right }, @duration, @easing)
    $('#chat_drawer').prepend(c.$top)
  else
    right = 8
    c.$top.show!.find('.Chat').css({ right })
    $('#chat_drawer').prepend(c.$top.show(@duration, @easing))
  c

Chat.stop = (key) ->
  c = @chats[key]
  if not c then return
  <~ c.$top.fade-out @duration
  c.$top.remove!
  @reorganize!
  delete @chats[key]

Chat.reorganize = ->
  $cs = $('#chat_drawer .Chat')
  width = $cs.first!width!
  n = $cs.length
  $cs.each (i,e) ->
    right = (n - i - 1) * (width + 8) + 8
    $(e).transition({ right }, @duration, @easing)

