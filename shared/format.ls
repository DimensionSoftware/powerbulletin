define = window?define or require(\amdefine) module
require, exports, module <- define

@render = (s, options={}) ->
  t0 = @replace-urls(s, @embedded)
  # TODO sanitize
  # https://code.google.com/p/pagedown/wiki/PageDown

@url-pattern = /(\w+:\/\/[\w\.\?\&=\%\/-]+[\w\?\&=\%\/-])/g

@replace-urls = (s, fn) ->
  s.replace @url-pattern, fn

@embedded = (url) ->
  if url.match /\.(jpe?g|png|gif)$/i
    """<img src="#{url}" />"""
  else
    """<a href="#{url}" target="_blank">#{url}</a>"""

@
