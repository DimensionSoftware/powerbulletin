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

    add-message: (text) ~>
      console.debug \add-message, text

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
    right = $cs.length * $cs.first!width!
    c.$top.show!.find('.Chat').animate({ right }, @duration, @easing)
    $('#chat_drawer').prepend(c.$top)
  else
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
    right = (n - i - 1) * width
    $(e).animate({ right }, @duration, @easing)

