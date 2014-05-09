define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  strftime
  furl: \./forum-urls
}

# XXX keep these functions pure as they're exported to the client & server

{Str, filter} = require \prelude-ls
{reverse,join,split} = Str

#{{{ String functions
@add-commas = (s) -> # 1234 -> 1,234
  s.to-string!
    |> reverse
    |> split /(\d{3})/
    |> filter (.length)
    |> join \, 
    |> reverse

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
    unless hours # only track minutes < an hr.
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

# XXX html is returned
@elapsed-to-human-readable = (secs-ago) ~>
  bold   = -> "<b>#it</b>"
  suffix = \ago
  human  = if secs-ago < 30s then bold 'Just now!'
  else if secs-ago < 60s then bold "a moment #{suffix}"
  else if secs-ago < 120s then bold "a minute #{suffix}"
  else if secs-ago < 86400s # within the day
     seconds-to-human-readable(secs-ago)+' '+suffix
  else if secs-ago < 172800s # within 2 days
    bold \Yesterday
  else if secs-ago < 604800s # within the week, use specific day
    d = new Date!
    d.set-time d.get-time!-(secs-ago*1000s)
    bold(@pretty-day-name d.get-day!)
  else if secs-ago < 2628000s # within a month
    weeks = Math.floor secs-ago / 604800s
    if weeks == 1 then "a #{bold \week} #{suffix}" else "#{weeks} weeks #{suffix}"
  else if secs-ago < 31446925s # within a year
    months = Math.floor secs-ago / 2628000s
    if months == 1 then "a #{bold \month} #{suffix}" else "#{months} months #{suffix}"
  else
    years = Math.floor secs-ago / 31446925s
    if years == 1 then "a #{bold \year} #{suffix}" else "#{years} years #{suffix}"
  human.replace /(\d+\s\w+)/g '<b>$1</b>' # bold numbers & metric

# ported from http://erlycoder.com/49/javascript-hash-functions-to-convert-string-into-integer-hash-
@djb2-hash = (str) ->
  hash = 5381
  for i in str
    char = str.char-code-at i
    hash = ((hash .<<. 5) + hash) + char
  hash

#}}}

# double-buffered replace of view with target
@render-and = (fn, w, target, tmpl, params, cb) -->
  $t = w.$ target  # target
  $b = w.$ \<div>  # buffer
  $b.hide!
  $t[fn] $b
  w.jade.render $b.0, tmpl, params
  $b.show!add-class \fadein
  if cb then cb $b
@render-and-append  = @render-and \append
@render-and-prepend = @render-and \prepend

@is-email = (name) ->
  name.index-of(\@) isnt -1
@is-forum-homepage = (path) ->
  furl.parse path .type is \forum
@is-editing = (path) ->
  meta = furl.parse path
  switch meta.type
  | \new-thread => true
  | \edit       => meta.id
  | otherwise   => false

# unbind reactive function from all dependencies
# (use with reactive.js ($R) library)
@r-unbind = !(rf) ->
  for d in rf.dependencies
    d.remove-dependent!

@parse-url = (url) ->
  if document?
    a = document.create-element \a
    a.href = url
    {a.search, a.pathname}
  else
    p = require(\url).parse url
    {p.search, p.pathname}

_date-fields =
  * \created
  * \updated

# recursively turn date-fields into Date objects
@add-dates = (o, date-fields=_date-fields) ~>
  now = Date.now!
  return o unless o
  switch typeof o
  | 'object' =>
    for df in date-fields
      if o[df]
        o[df] = new Date o[df]
        o["#{df}_human"] = @elapsed-to-human-readable ((now - o[df]) / 1000)
        o["#{df}_iso"] = o[df].toISOString()
        o["#{df}_friendly"] = @friendly-date-string o[df]
    sub = keys(o) |> filter (k) -> typeof o[k] == 'array' || typeof o[k] == 'object'
    for k in sub
      o[k] = @add-dates o[k]
    o
  | 'array' =>
    for v,i in o
      if typeof v == 'object'
        o[i] = @add-dates o[i]
    o
  | otherwise => o

# A date in "friendly" format.  This is for absolute times (NOT elapsed times).
@friendly-date-string = (d) ->
  strftime "%A - %b %e, %Y @ %I:%M %p", d

# # Return a timezone-adjusted date from a date-string.
# @tz-adjusted-date = (date-string) ->
#   date = new Date(date-string)
#   tz-offset = (new Date).get-timezone-offset! * 60 * 1000
#   new-date = new Date(date - -tz-offset)
#   console.log \old-vs-new, date, new-date
#   new-date

@
# vim:fdm=marker
