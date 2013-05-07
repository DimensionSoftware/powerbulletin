require! {
  __: \lodash
}

# XXX keep these functions pure as they're exported to the client & server

#{{{ String functions
@add-commas = (s) -> # 1234 -> 1,234
  (s |> reverse) .split /(\d{3})/ .filter (.length) .join \, |> reverse

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
      timestring += ' and '

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

# vim:fdm=marker
