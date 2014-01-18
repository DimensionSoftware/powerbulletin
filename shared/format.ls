define = window?define or require(\amdefine) module
require, exports, module <- define

# tags to exclude when regexing
excludes =
  HTML   : 1
  HEAD   : 1
  STYLE  : 1
  TITLE  : 1
  META   : 1
  SCRIPT : 1
  LINK   : 1
  OBJECT : 1
  IFRAME : 1

# $.fn.regex :: jQuery plugin version of findAndReplace()
jquery-regex-plugin = ($) ->
  regex: (pattern, replacement) ->
    @each ->
      parent = this
      #console.log '<' + this.node-name + '>'

      $(this).contents().each ->
        #console.log \node-type, this.node-type
        switch this.nodeType

          # element node -> recurse to get more text nodes
          when 1
            if not excludes[this.node-name]
              #console.log '.'
              $(this).regex(pattern, replacement)

          # text node -> regex pattern replacement
          when 3
            #console.log 'x'
            html = this.data.replace(pattern, replacement)
            document = $(this)[0]._owner-document
            frag = document.create-document-fragment!
            wrap = $('<div>' + html + '</div>')[0]
            while (wrap.first-child)
              frag.append-child(wrap.first-child)
            parent.insert-before(frag, this)
            parent.remove-child(this)

            # You can stop processing by setting replacement.break to true.
            if replacement.break
              throw "BreakRequested"

# regex to match urls
url-pattern = /(\w+:\/\/[\w\.\?\&=\%\/-]+[\w\?\&=\%\/-])/g

replace-urls = (s, fn) ->
  s.replace url-pattern, fn

# given a url, return its hostname
hostname = (url) ->
  url.match(/^https?:\/\/(.*?)\//)?1

# given a url, find a way to embed it in html
embedded = (url) ->
  h = hostname url
  if url.match /\.(jpe?g|png|gif)$/i
    """<a href="#{url}" target="_blank"><img src="#{url}" /></a>"""
  else if h is \www.youtube.com and url.match(/v=(\w+)/)
    [m,v] = url.match(/v=(\w+)/)
    """<iframe width="560" height="315" src="//www.youtube.com/embed/#v" frameborder="0" allowfullscreen></iframe>"""
  else
    """<a href="#{url}" target="_blank">#{url}</a>"""

# Generate a markup to HTML function
#
# @param    {Object}   converter   an object that has a make-html method (like pagedown)
# @param    {Function} $fn         a function that takes HTML and wraps it in jQuery
# @returns  {Function}             a function to turn our markup into HTML
@render-fn = (converter, $fn) ->
  fn = (markup, options, cb) ->
    t0 = converter.make-html markup
    err, w <- $fn t0
    if err then return cb err
    $ = w.$
    if not $.fn.regex
      $.fn.extend jquery-regex-plugin($)
    if w.name is \nodejs # assume we're using jsdom
      $('body').regex url-pattern, embedded
      cb null, $('body').0.inner-HTML
    else # assume client-side jquery
      $t = $("""<div>#t0</div>""").regex url-pattern, embedded
      cb null, $t.html!

@

# Example:
#
# require! { \jsdom, \pagedown, \./shared/format }
# cv = pagedown.get-sanitizing-converter!
# jq = (html, cb) -> jsdom.env html, [ '../public/local/jquery-1.10.2.min.js' ], cb
# r  = format.render-fn cv, jq
# x  = {}
# x.err, x.r <- r "# http://foo.com/img.jpg\n\n* one\n* two\n* three", {}
