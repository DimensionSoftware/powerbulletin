define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  markdown
}
{id, is-type, concat, map} = require \prelude-ls
md = if markdown.markdown then markdown.markdown else markdown

@util = util = {}

# $RE{URI}{HTTP} from Regexp::Common::URI
url-pattern = '''(?:(?:https?)://(?:(?:(?:(?:(?:(?:[a-zA-Z0-9][-a-zA-Z0-9]*)?[a-zA-Z0-9])[.])*(?:[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]|[a-zA-Z])[.]?)|(?:[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)))(?::(?:(?:[0-9]*)))?(?:/(?:(?:(?:(?:(?:(?:[a-zA-Z0-9-_.!~*'():@&=+]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9-_.!~*'():@&=+]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*)(?:/(?:(?:(?:[a-zA-Z0-9-_.!~*'():@&=+]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9-_.!~*'():@&=+]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*))*))(?:[?](?:(?:(?:[;/?:@&=+a-zA-Z0-9-_.!~*'()]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)))?))?)'''
@util.url-pattern     = new RegExp url-pattern, 'i'
@util.url-pattern-all = new RegExp url-pattern, 'ig'

@util.replace-urls = (s, fn) ->
  s.replace util.url-pattern-all, fn

md-ref-pattern = '(\\s*)\\[(\\w+)\\]:\\s*(http\\S+)'
@util.md-ref-pattern     = new RegExp '^' + md-ref-pattern, 'im'
@util.md-ref-pattern-all = new RegExp '^' + md-ref-pattern, 'img'

# given a url, return its hostname
@util.hostname = (url) ->
  url.match(/^https?:\/\/(.*?)\//)?1

# given a url, find a way to embed it in html
@util.embedded = (url) ->
  h = util.hostname url
  if url.match /\.(jpe?g|png|gif)$/i
    #"""<a href="#{url}" target="_blank"><img src="#{url}" /></a>"""
    [ \a, { href: url, target: \_blank }, [ \img, { src: url } ] ]
  else if h is \www.youtube.com and url.match(/v=(\w+)/)
    [m,v] = url.match(/v=([\w\-]+)/)
    #"""<iframe width="560" height="315" src="//www.youtube.com/embed/#v" frameborder="0" allowfullscreen></iframe>"""
    [ \iframe { width: '560', height: '315', src: "//www.youtube.com/embed/#v", frameborder: '0', allowfullscreen: 'true' } ] # TODO instead of an iframe, do something that delays loading flash
  else
    #"""<a href="#{url}" target="_blank">#{url}</a>"""
    [ \a, { href: url, target: \_blank }, url ]

# given a string, split it on pattern, but include the matched text as well.
@util.split = _split = (string, pattern, fn) ->
  m = string.match pattern
  if m
    if m.index is 0
      rest = string.substring(m.0.length)
      if rest.length
        [m.0, ...(_split rest, pattern)]
      else
        [m.0]
    else if m.index > 0
      rest = string.substring(m.index + m.0.length)
      if rest.length
        [string.substring(0, m.index), m.0, ...(_split rest, pattern)]
      else
        [string.substring(0, m.index), m.0]
  else
    [string]

# recurse through the tree and make transformations
@transform = transform = (fn, tree) -->
  [tag, attrs, children] = if is-type \String, tree
    [void, void, tree]
  else if is-type \Array, tree
    if is-type \Object, tree.1
      if tree.length > 2
        [tree.0, tree.1, tree.slice(2)]
      else
        [tree.0, tree.1]
    else
      [tree.0, {}, tree.slice(1)]

  if tag
    if children and children.length

      # this loop was so hard to figure out
      new-children = []
      for c in children
        nc = transform fn, c
        if (is-type \String, c) and (is-type \Array, nc)
          new-children = new-children.concat nc
        else
          new-children.push nc

      [tag, attrs, ...new-children]
    else
      [tag, attrs]
  else
    fn children

@tx = tx = {}

# take a string and return JsonML for embedded links
@tx.auto-embed-link = (s) ->
  r = util.split s, util.url-pattern
  |> map (-> if it.match(util.url-pattern) then [util.embedded(it)] else it)
  |> concat # just flatten one level

# turn newlines into br tags
@tx.new-line = (s) ->
  r = util.split s, /\n/
  |> map (-> if it.match(/\n/) then [[\br {}]] else it)
  |> concat

# #hashtag support
@tx.hash-tag = (s) ->
  hashtag = /#\w+/
  r = util.split s, hashtag
  |> map (-> if it.match(hashtag) then [[\a, { class:"mutant hash-tag", href:"/search?q=#{encode-URI-component it.to-lower-case!}" }, it ]] else it)
  |> concat

# @mention (aka at-tag) support
@tx.at-tag = (s) ->
  mention = /@[\w-]+/
  r = util.split s, mention
  |> map (-> if it.match(mention) then [[\a, { class:"mutant at-tag", href:"/user/#{encode-URI-component it.replace(/^@/, '')}" }, it ]] else it)
  |> concat

# TODO - bbcode support
@tx.bbcode = (s) ->

# prepare text before parsing
#
#   Some people, when confronted with a problem, think
#   “I know, I'll use regular expressions.”
#   Now they have two problems.
#   -jwz
#
# http://regex.info/blog/2006-09-15/247
@escape = escape = (text) ->
  e1 = util.replace-urls text, (url) -> url.replace /_/g, '\\_'
  e2 = e1.replace util.md-ref-pattern-all, (m) -> m.replace /\\_/g, '_'  # unescape \\_ in markdown image references
  e3 = e2.replace /^\s{4,}.*$/mg, (m) -> m.replace /\\_/g, '_'           # unescape \\_ in markdown indented code blocks

# take text and apply markup rules to it
@parse = parse = (text) ->
  esc-text = escape text
  tree = md.parse esc-text
  |> md.to-HTML-tree
  |> transform tx.auto-embed-link
  |> transform tx.hash-tag
  |> transform tx.at-tag
  |> transform tx.new-line

# take parsed tree and render html
@render = render = (text) ->
  unless text?length then return '' # guard
  tree = parse text
  md.render-json-ML tree

# create a custom render function
@render-fn = (before-filters, transforms) ->
  (text) ->
    filtered-text = before-filters |> fold ((text, filter) -> filter(text)), text
    tree          = filtered-text  |> md.parse |> md.to-HTML-tree
    tx-tree       = transforms     |> fold ((html-tree, tx) -> transform tx, html-tree), tree
    md.render-json-ML tx-tree

@

# vim:fdm=indent
