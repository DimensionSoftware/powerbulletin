require! {
  __: \lodash
  auth: \./auth
}

# XXX keep these functions pure as they're exported to the client & server

#{{{ String functions
@add-commas = (s) -> # 1234 -> 1,234
  (s |> Str.reverse) .split /(\d{3})/ .filter (.length) .join \, |> Str.reverse

@title-case = (s) ->
  s?replace /[\w]\S*/g, (word) ->
    if word==word.to-upper-case! # oh n0ez--a potential caps-locker
      if word.index-of('.')>-1 or word.index-of('-')>-1 or word.length<6 # it's an abbreviation, after all
        return word
    if word.length > 3 # title case it!
      return word[0].to-upper-case! + word.substr(1).to-lower-case!
    word

@ellipse = (s, len, suffix='...') ->
  if s?length > len
    s = s.substr(0 len) # chop
    s = s.substr(0 s.last-index-of(' '))+suffix if s.last-index-of(' ') > 0 # trunc
  s

#}}}
#{{{ Time functions
# human readable day name based on int
@day-name = (i) ->
  switch i
    when 0 then 'sun'
    when 1 then 'mon'
    when 2 then 'tue'
    when 3 then 'wed'
    when 4 then 'thu'
    when 5 then 'fri'
    when 6 then 'sat'

@pretty-day-name = (i) ->
  switch i
    when 0 then 'Sunday'
    when 1 then 'Monday'
    when 2 then 'Tuesday'
    when 3 then 'Wednesday'
    when 4 then 'Thursday'
    when 5 then 'Friday'
    when 6 then 'Saturday'

seconds-to-human-readable = (secs) ->
  hours = Math.floor secs / (60 * 60)
  secs -= hours * (60 * 60)
  minutes = Math.floor secs / 60
  secs -= minutes * 60
  seconds = secs

  timestring = ''
  if hours > 1
    timestring += hours + ' hours'
  else if hours == 1
    timestring += '1 hour'

  if minutes
    if hours
      timestring += ', '

    if minutes > 1
      timestring += minutes + ' minutes'
    else if minutes == 1
      timestring += '1 minute'
  else if not hours
    if secs == 1
      timestring = "#{secs} second"
    else
      timestring = "#{secs} seconds"
  timestring

@elapsed-to-human-readable = (secs-ago) ->
  suffix = \ago
  human  = if secs-ago < 30s then 'Just now!'
  else if secs-ago < 60s then "A moment #{suffix}"
  else if secs-ago < 120s then "A minute #{suffix}"
  else if secs-ago < 86400s # within the day
     seconds-to-human-readable(secs-ago)+' '+suffix
  else if secs-ago < 172800s # within 2 days
    \Yesterday
  else if secs-ago < 604800s # within the week, use specific day
    d = new Date!
    d.set-time d.get-time!-(secs-ago*1000s)
    @pretty-day-name d.get-day!
  else if secs-ago < 2628000s # within a month
    weeks = Math.floor secs-ago / 604800s
    if weeks == 1 then "A week #{suffix}" else "#{weeks} weeks #{suffix}"
  else if secs-ago < 31446925s # within a year
    months = Math.floor secs-ago / 2628000s
    if months == 1 then "A month #{suffix}" else "#{months} months #{suffix}"
  else
    years = Math.floor secs-ago / 31446925s
    if years == 1 then "A year #{suffix}" else "#{years} years #{suffix}"
  human.replace /(\d+)/g '<b>$1</b>' # bold numbers

# ported from http://erlycoder.com/49/javascript-hash-functions-to-convert-string-into-integer-hash-
@djb2-hash = (str) ->
  hash = 5381
  for i in str
    char = str.char-code-at i
    hash = ((hash .<<. 5) + hash) + char
  hash


date-fields =
  * \created
  * \updated

# recursively turn date-fields into Date objects
@add-dates = (o) ->
  now = Date.now!
  return o unless o
  switch typeof o
  | 'object' =>
    for df in date-fields
      if o[df]
        o[df] = new Date o[df]
        o["#{df}_human"] = @elapsed-to-human-readable ((now - o[df]) / 1000)
        o["#{df}_iso"] = o[df].toISOString()
    sub = __.keys(o).filter (k) -> typeof o[k] == 'array' || typeof o[k] == 'object'
    for k in sub
      o[k] = @add-dates o[k]
    o
  | 'array' =>
    for v,i in o
      if typeof v == 'object'
        o[i] = @add-dates o[i]
    o
  | otherwise => o
#}}}

@register-local-user = (site, username, password, email, cb=(->)) ->
  err, r <~ db.name-exists name:username, site_id:site.id
  if err
    return cb 'Account in-use'
  else if r
    return cb 'User name in-use'
  else
    err, vstring <~ auth.unique-hash \verify, site.id
    if err then return cb err
    u =
      type    : \local
      profile : { password: auth.hash(password) }
      site_id : site.id
      name    : username
      email   : email
      verify  : vstring
    err, r <~ db.register-local-user u # couldn't use find-or-create-user because we don't know the id beforehand for local registrations
    if err then return cb err
    #@login(req, res, cb) # on successful registration, automagically @login, too
    cb null, u

# double-buffered replace of view with target
@render-and = (fn, w, target, tmpl, params, cb) -->
  $t = w.$ target  # target
  $b = w.$ \<div>  # buffer
  $b.hide!
  $t[fn] $b
  w.jade.render $b.0, tmpl, params
  $b.show!add-class \fadein
  set-timeout (-> cb $b), 100ms # XXX race condition
@render-and-append  = @render-and \append
@render-and-prepend = @render-and \prepend

@is-forum-homepage = (path) ->
  furl.parse path .type is \forum
@is-editing = (path) ->
  meta = furl.parse path
  switch meta.type
  | \new-thread => true
  | \edit       => meta.id
  | otherwise   => false

@remove-editing-url = (meta) ->
  History.replace-state {no-surf:true} '' meta.thread-uri

@scroll-to-edit = (cb) ->
  cb = -> noop=1 unless cb
  id = is-editing window.location.pathname
  if id then # scroll to id
    awesome-scroll-to "\#post_#{id}" 600ms cb
    true
  else
    scroll-to-top cb
    false

# handle in-line editing
@edit-post = (id, data={}) ->
  focus  = ($e) -> set-timeout (-> $e.find 'input[type="text"]' .focus!), 100ms
  render = (sel, locals) ~>
    $e = $ sel
    @render-and-append window, sel, \post-edit, {user:user, post:locals}, ($e) ->
      # init sceditor
      $e.find \textarea.body .sceditor(
        plugins:        \bbcode
        style:          "#{window.cache-url}/local/jquery.sceditor.default.min.css"
        toolbar:        'bold,italic,underline|image,link,youtube|emoticon|source'
        width:          \85%
        emoticons-root: "#{window.cache-url}/")
      $e.find \.sceditor-container .prepend($e.find \.title) # place title inside
      focus $e

  if id is true # render new
    scroll-to-top!
    data.action = \/resources/post
    data.method = \post
    render \.forum, data
  else # fetch existing & render
    sel = "\#post_#{id}"
    e   = $ sel
    unless e.find("\#post_edit_#{id}:visible").length # guard
      scroll-to-edit!
      $.get "/resources/posts/#{id}" (p) ->
        render sel, p
        e .add-class \editing
    else
      focus e

@submit-form = (event, fn) -> # form submission
  $f = $ event.target .closest(\form) # get event's form
  $s = $ $f.find('[type=submit]:first')
  $s.attr \disabled \disabled

  # update textarea body from sceditor
  $e = $ \textarea.body
  $e.html $e.data!sceditor?val! if $e.length and $e.data!sceditor

  $.ajax {
    url:      $f.attr(\action)
    type:     $f.attr(\method)
    data:     $f.serialize!
    data-type: \json
    success:  (data) ->
      $s.remove-attr \disabled
      if fn then fn.call $f, data
    error: ->
      $s.remove-attr \disabled
      show-tooltip $($f.find \.tooltip), 'Try again!'
  }
  false

@respond-resize = ->
  w = $ window
  if w.width! <= 800px then $ \body .add-class \collapsed

@align-breadcrumb = ->
  b = $ \#breadcrumb
  m = $ \#main_content
  l = $ \#left_content
  pos = (m.width!-b.width!)/2
  b.transition {left:(if pos < l.width! then l.width! else pos)}, 300ms \easeOutExpo

@flip-background = (w, cur, direction=\down) ->
  clear-timeout w.bg-anim if w.bg-anim
  last = w.$ \.bg.active
  next = w.$ \#forum_bg_ + cur.data \id
  next.css \display \block
  unless last.length
    next.add-class \active
  else
    w.bg-anim := set-timeout (->
      last.css \top if direction is \down then -300 else 300 # stage animation
      last.remove-class \active
      next.add-class \active # ... and switch!
      w.bg-anim = 0
    ), 100

# unbind reactive function from all dependencies
# (use with reactive.js ($R) library)
@r-unbind = !(rf) ->
  for d in rf.dependencies
    d.remove-dependent!

# vim:fdm=marker
