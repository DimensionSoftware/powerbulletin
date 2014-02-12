define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  md: markdown.markdown
}
{id, is-type} = require \prelude-ls

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
  #if url.match /\.(jpe?g|png|gif)$/i
  #  """<a href="#{url}" target="_blank"><img src="#{url}" /></a>"""
  if h is \www.youtube.com and url.match(/v=(\w+)/)
    [m,v] = url.match(/v=(\w+)/)
    """<iframe width="560" height="315" src="//www.youtube.com/embed/#v" frameborder="0" allowfullscreen></iframe>"""
  else
    """<a href="#{url}" target="_blank">#{url}</a>"""

# recurse through the tree and make transformations
@transform = (tree, fn=id) ->
  [tag, attrs, children] = if is-type \String, tree
    [void, void, tree]
  else if is-type \Array, tree
    if is-type \Object, tree.1
      if tree.length > 3
        [tree.0, tree.1, tree.slice(2)]
      else
        [tree.0, tree.1]
    else
      [tree.0, {}, tree.slice(1)]

  if tag
    if children and children.length
      new-children = [@transform(c, fn) for c in children]
      [tag, attrs, ...new-children]
    else
      [tag, attrs]
  else
    new-children = fn children


# take text and apply markup rules to it
@render = (text) ->
  tree = md.parse text |> md.to-HTML-tree
  tree |> md.render-json-ML

@

# Example:
#
# require! { \pagedown, \./shared/format }
# cv = format.cv pagedown.get-sanitizing-converter!
# cv.make-html "# http://foo.com/img.jpg\n\n* one\n* two\n* three", {}
