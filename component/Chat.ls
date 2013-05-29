require! \./Component.ls

{templates} = require \../build/component-jade.js

module.exports =
  class Chat extends Component
    template: templates.Chat

    attach: ~>
      @$top.on(\click, \.minimize, @minimize)
      @$top.on(\click, \.close, @close)

    detach: !->
      @$top.find \.minimize .off!
      @$top.find \.close .off!

    add-message: (text) ~>
      console.debug \add-message, text

    load-more-messages: (offset, limit=8) ~>
      console.debug \load-more-messages, offset, limit
      r <- $.get '/resources/chats/messages', {}

    minimize: (state=true) ~>
      console.debug \minimize
      @$top.add-class \minimized, state

    close: ~>
      console.debug \close
      @$top.remove()

Chat.start = ([me,...others]:users) ->
  duration = 300ms
  easing   = \easeOutExpo
  c = new Chat { me, others }, $('<div/>').hide!
  c.render!
  c.put!
  $cf = $('#chat_drawer .Chat')
  if $cf.length
    console.debug \if, c.$top
    right = $cf.length * $cf.first!width!
    c.$top.show!.find('.Chat').animate({ right }, duration, easing)
    $('#chat_drawer').prepend(c.$top)
  else
    console.debug \else, c.$top
    $('#chat_drawer').prepend(c.$top.show(duration, easing))
  c
