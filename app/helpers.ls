require! {
  crypto
}

# XXX keep these functions pure as they're exported in the app & eventually (TODO) on the client via browserify

shouldnt-cache = !((process.env.NODE_ENV == 'production') or process.env.TEST_VARNISH)
@caching-strategies =
  nocache: (res) ->
    # upstream caches and clients should not cache
    res.header 'X-Varnish-TTL', "0s"
    res.header 'Cache-Control', 'no-cache'
    res.header 'Pragma', 'no-cache'
  etag: (res, etag, client_ttl, varnish_ttl = null) ->
    res.header 'X-Varnish-TTL', "#{varnish_ttl}s" if varnish_ttl
    res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"
    res.header 'ETag', etag
  lastmod: (res, last_modified, client_ttl, varnish_ttl = null) ->
    res.header 'X-Varnish-TTL', "#{varnish_ttl}s" if varnish_ttl
    res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"
    res.header 'Last-Modified', last_modified.toUTCString()
  justage: (res, client_ttl, varnish_ttl = null) ->
    res.header 'X-Varnish-TTL', "#{varnish_ttl}s" if varnish_ttl
    res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"

#{{{ String functions
@title-case = (s) ->
  s?.replace /[\w]\S*/g, (word) ->
    if word==word.to-upper-case! # oh n0ez--a potential caps-locker
      if word.index-of('.')>-1 or word.index-of('-')>-1 or word.length<6 # it's an abbreviation, after all
        return word
    if word.length > 3 # title case it!
      return word[0].to-upper-case! + word.substr(1).to-lower-case!
    word

@ellipse = (s, len, suffix='...') ->
  if s?.length > len
    s = s.substr(0 len) # chop
    s = s.substr(0 s.last-index-of(' '))+suffix if s.last-index-of(' ') > 0 # trunc
  s

@title-case = (s) ->
  s?.replace /[\w]\S*/g, (word) ->
    if word is word.to-upper-case! # oh n0ez--a potential caps-locker
      if word.index-of('.')>-1 or word.index-of('-')>-1 or word.length<6 # it's an abbreviation, after all
        return word
    if word.length > 3 # title case it!
      return word[0].to-upper-case! + word.substr 1 .to-lower-case!
    word

@ellipse = (s, len, suffix='...') ->
  if s?.length > len
    s = s.substr(0, len) # chop
    s = s.substr(0, s.last-index-of ' ')+suffix if s.last-index-of ' ' > 0 # trunc
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

@seconds-to-human-readable = (secs) ->
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
  suffix = ' ago'
  if secs-ago < 30 then 'just now!'
  else if secs-ago < 60 then "a moment #{suffix}"
  else if secs-ago < 120 then "a minute #{suffix}"
  else if secs-ago < 86400 # within the day
     @seconds-to-human-readable(secs-ago)+suffix
  else if secs-ago < 172800 # within 2 days
    \Yesterday
  else if secs-ago < 604800 # within the week, use specific day
    d = new Date!
    d.set-time d.get-time!-(secs-ago*1000)
    @pretty-day-name d.get-day!
  else if secs-ago < 2628000 # within a month
    weeks = Math.floor secs-ago / 604800
    if weeks == 1 then "a week #{suffix}" else "#{weeks} weeks #{suffix}"
  else if secs-ago < 31446925 # within a year
    months = Math.floor secs-ago / 2628000
    if months == 1 then "a month #{suffix}" else "#{months} months #{suffix}"
  else
    years = Math.floor secs-ago / 31446925
    if years == 1 then "a year #{suffix}" else "#{years} years #{suffix}"

# meant to be used for etags
@sha1 = (str) ->
  str = crypto.create-hash('sha1').update(str).digest('hex')
  # supposedly the quotes are the proper way to format this, trying to follow rfcs
  '"' + str + '"'

#}}}
# vim:fdm=marker
