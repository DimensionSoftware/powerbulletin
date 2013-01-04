
@caching-strategies =
  nocache: (res) ->
    # upstream caches and clients should not cache
    res.header 'X-Varnish-TTL', "0s"
    res.header 'Cache-Control', 'no-cache'
    res.header 'Pragma', 'no-cache'
  etag: (res, etag, client_ttl, varnish_ttl = 3600) ->
    if process.env.NODE_ENV != 'production' then @nocache(res) else
      res.header 'X-Varnish-TTL', "#{varnish_ttl}s"
      res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"
      res.header 'ETag', etag
  lastmod: (res, last_modified, client_ttl, varnish_ttl = 3600) ->
    if process.env.NODE_ENV != 'production' then @nocache(res) else
      res.header 'X-Varnish-TTL', "#{varnish_ttl}s"
      res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"
      res.header 'Last-Modified', last_modified.toUTCString()
  justage: (res, client_ttl, varnish_ttl = 3600) ->
    if process.env.NODE_ENV != 'production' then @nocache(res) else
      res.header 'X-Varnish-TTL', "#{varnish_ttl}s"
      res.header 'Cache-Control', "max-age=#{client_ttl}; must-revalidate"

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
