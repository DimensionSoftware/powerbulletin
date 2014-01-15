define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \pagedown
}

converter = pagedown.get-sanitizing-converter!

@render = (s, options={}) ->
  t0 = @replace-urls(s, @embedded)
  t1 = converter.make-html t0

@url-pattern = /(\w+:\/\/[\w\.\?\&=\%\/-]+[\w\?\&=\%\/-])/g

@replace-urls = (s, fn) ->
  s.replace @url-pattern, fn

@embedded = (url) ->
  if url.match /\.(jpe?g|png|gif)$/i
    """<img src="#{url}" />"""
  else
    """<a href="#{url}" target="_blank">#{url}</a>"""

@
