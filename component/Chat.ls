define = window?define or require(\amdefine) module
require, exports, module <- define

require! Component: yacomponent
{templates} = require \../build/component-jade
{join, map, sort-with, Obj} = require \prelude-ls

add-message = (fn, m) -->
  $msg = @message-node m
  $messages = @$.find(\.messages)[fn] $msg
  $msg.show!
  $messages.0.scroll-top = $messages.0.scroll-height
  @$.find \textarea .val ''

module.exports =
  class Chat extends Component
    @duration  = 300ms
    @easing    = \easeOutExpo
    @chats     = {}

    conversation: null
    template: templates.Chat

    remember-chat: ->
      chats = [] #JSON.parse( $.cookie('chats') || '[]' )
      id = @conversation?id
      if chats.index-of(id) == -1 and id
        chats.push id
        $.cookie 'chats', JSON.stringify(chats), { path: '/' }
      else
        console.warn chats.index-of(id), id

    forget-chat: ->
      chats = [] #JSON.parse( $.cookie('chats') || '[]' )
      id = @conversation?id
      i = chats.index-of(id)
      if i != -1 and id
        chats.splice i, 1
        #$.cookie 'chats', JSON.stringify(chats), { path: '/' }
      else
        console.warn chats.index-of(id), id

    on-attach: ~>
      @$.draggable {
        snap: \footer
        snap-mode: \outer
        cursor: \move
        start: (ev) ->
          $ ev.target .find(\.minimize).add-class \no-click } .css {left:50, bottom:335}
      @$.on \click,    \.minimize,  @minimize
      @$.on \click,    \.close,     @close
      @$.on \keydown,  \textarea,   @send-message

      @$.find(\.messages).scroll @maybe-load-more

    on-detach: !~>
      #@$.find \.minimize .off!
      #@$.find \.close .off!

    key: ~>
      [me,others] = [@state.me.val, @state.others.val]
      "#{me.name}/#{others.map((-> it.name)).join '/'}"

    users: ~>
      flatten [@state.me.val, @state.others.val] |> fold ((m, u) -> m[u.id] = u; m), {}

    message-from-env: ~>
      u = @state?others?val?0
      m =
        conversation_id: @conversation?id
        from           : window.user
        to             : {id: u.id, name: u.name}
        body           : @$.find('textarea').val!

    message-node: (m) ~>
      console.warn \m, m
      $msg = @$.find('.container > .msg').clone!
      $msg.attr('data-message-id', m.id)
      if m.created_human
        $msg.find('.body').attr('title', m.created_human.replace(/<.*?\/?>/g, '')).attr('data-time', m.created_iso).add-class('time-title').html(m.body)
      else
        console.warn "missing m.created_human", m
        $msg.find('.body').html(m.body)
      $msg.find('a.from-name').attr('href', "/user/#{m.from.name}").html m.from.name
      my-name = @state.me?val?name
      if m.from.name is not my-name
        $msg.add-class \other
      $msg

    send-message: (ev) ~>
      if ev.key-code is 13
        m = @message-from-env!
        console.log \m, m
        if m.body.match /^\s*$/
          return false
        err, r <~ socket.emit \chat-message, m
        if err
          console.error err
          return
        if (@conversation is null)
          @conversation = r.conversation
        console.log \r, r
        m.id = r.message.id
        m.body = r.message.body
        console.log \r, r.message
        @append-message m

    append-message: add-message \append

    prepend-message: add-message \prepend

    maybe-load-more: (ev) ~>
      if @loaded-all then return false
      pos = $ ev.target .scroll-top!
      if pos is 0
        @load-more-messages!

    load-more-messages: (last) ~>
      $first-msg = @$.find '.messages .msg:first'
      last ||= $first-msg.data \message-id
      r <~ $.get "/resources/conversations/#{@conversation.id}", { last }
      if r.success
        id = r.messages[0]?id
        if (not id) or id >= last
          @loaded-all = true
          return
        users = @users!
        r.messages
        |> map  (~> it.from = users[it.user_id]; it)
        |> each (~> @prepend-message it)
        @$.find \.messages .scroll-top( 0 + 50 )

    minimize: (ev) ~>
      e = $ ev.target
      if e.has-class \no-click # click from draggable
        e.remove-class \no-click
      else
        @$.toggle-class \minimized
        @$.find \textarea .focus!

    close: ~>
      key = @key!
      Chat.stop(@key!)
      err, r <~ socket.emit \chat-leave, @conversation

Chat.start = ([me,...others]:users, messages=[], x=null, y=null) ->
  # TODO setup profile here
  key = map (.name), users |> join '/'
  if c = @chats[key]
    return c
  $div = $('<div/>').hide!
  c = @chats[key] = new Chat locals: { me, others }, $div
  if (x or y)
    set-timeout (->
      $div
        .show(@duration, @easing)
        .css({ top: '', left: '' })
        .transition({ bottom: y, right: x })
    ), 2000ms
  else
    c.$.show!
  $ \#chat_drawer .after c.$
  r <- $.post '/resources/conversations', { site_id: window.site-id, users }
  console.log \r, r
  if r.messages.length > 0 and messages.length == 0
    messages := r.messages
  for m in messages
    c.prepend-message m
  c.$.find \textarea .focus!
  c.conversation = r
  c.remember-chat!
  c

Chat.stop = (key) ->
  c = @chats[key]
  if not c then return
  <~ c.$.fade-out @duration
  c.$.empty!remove!
  @reorganize!
  c.forget-chat!
  delete @chats[key]

Chat.reorganize = ->
  $cs = $('#chat_drawer .Chat')
  width = $cs.first!width!
  n = $cs.length
  $cs.each (i,e) ->
    right = (n - i - 1) * (width + 8) + 8
    $(e).transition({ right }, @duration, @easing)

Chat.remember = ->
  ids = [] #JSON.parse( $.cookie('chats') || '[]' )
  x = 0 + 8
  y = $(\footer).height! - 14

  for id in ids
    console.log \chat-join-and-open, id
    do ->
      c <- $.get "/resources/conversations/#id"
      console.log \c, c
      if c
        me-first = (a, b) ->
          | a.name is window.user?name => -1
          | otherwise                  =>  1
        people = sort-with me-first, c.participants
        console.log \x-y, x, y
        chat = Chat.start people, c.messages, x, y
        x := x + 220 + 8
      else
        console.warn \no-chat, id

Chat.client-socket-init = (socket) ->

  socket.on \chat-open, (conversation, cb) ->
    console.warn "received request to open chat #{conversation.id}", conversation
    err, c2 <- socket.emit \chat-join, conversation
    console.log \after-chat-join, err, c2
    me-first = (a, b) ->
      | a.name is window.user?name => -1
      | otherwise                  =>  1
    people = sort-with me-first, conversation.participants
    names  = map (.name), people
    key    = names.join '/'
    console.log \kkk, key, Chat.chats[key]
    return if Chat.chats[key]
    c = Chat.start people, conversation.messages
    console.warn \after-chat-start
    c.conversation = conversation
    c.room = c2.room
    console.warn \end-of-chat-open, c == Chat.chats[key], c

  socket.on \chat-message, (msg, cb) ~>
    console.log \incoming-chat, msg
    return if msg.from.id is user?id
    # load appropriate chat instance
    c = Obj.find (-> it.conversation?id is msg.conversation_id), Chat.chats
    if c
      # add message to that chat
      c.append-message msg
    else
      console.warn \chat-message, 'c not found', msg

  Chat.remember!
