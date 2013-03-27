
# XXX shared by pb_mutants & pb_entry

# double-buffered replace of view with target
@insert-dom = (w, target, tmpl, params) ->
  $t = w.$ target
  $b = w.$ "<div class='container'>"
  $b.hide!
  $t.prepend $b
  jade.render $b.0, tmpl, params
  console.log "rendered #{tmpl} to #{params}"
  $b.show!add-class \fadein

@is-editing-regexp = /(edit|new)\/?([\d+]*)/

@is-editing = ->
  m = window.location.pathname.match @is-editing-regexp
  return if m then m[2] else false

@remove-editing-url = ->
  if window.location.href.match @is-editing-regexp
    History.push-state {no-surf:true} '' window.location.href.replace(@is-editing-regexp, '')

@scroll-to-edit = ->
  id = is-editing!
  if id then # scroll to id
    awesome-scroll-to "\#subpost_#{id}"
    true
  else
    scroll-to-top!
    false

# handle in-line editing
@edit-post = (id, data) ->
  focus  = (e) -> set-timeout (-> e.find 'input[type="text"]' .focus!), 100
  render = (sel, locals) ->
    e = $ sel
    insert-dom window, sel, \post_edit, post:locals
    focus e

  scroll-to-edit!
  if not id.length and data # render new
    data.action = '/resources/post'
    data.method = \post
    render '.forum.new', data
  else # fetch existing & render
    sel = "\#subpost_#{id}"
    e   = $ sel
    unless e.find('.container:first:visible').length # guard
      $.get "/resources/posts/#{id}" (p) ->
        render sel, p?0
        e .add-class \editing
    else
      focus e

@align-breadcrumb = ->
  b = $ '.breadcrumb'
  m = $ '.menu'
  b.css \left ((m.width! - b.width!)/2 + m.offset!left)

# vim:fdm=indent
