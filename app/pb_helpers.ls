
# XXX shared by pb_mutants & pb_entry

# double-buffered replace of view with target
@insert-dom = (w, target, tmpl, params) ->
  $t = w.$ target
  $b = w.$ "<div class='container'>"
  $b.hide!
  $t.prepend $b
  jade.render $b[0], tmpl, params
  $b.show!add-class \shrink

@is-editing = ->
  m = window.location.pathname.match /(edit|new)\/?([\d+]*)/
  return if m then m[2] else false

@scroll-to-edit = ->
  id = is-editing!
  if id then # scroll to id
    awesome-scroll-to "\#subpost_#{id}"
    true
  else
    false

# handle in-line editing
@edit-post = (id) ->
  return unless id # guard
  scroll-to-edit!
  sel = if id then "\#subpost_#{id}" else \BOTTOM
  $.get "/resources/posts/#{id}" (p) ->
    insert-dom window, sel, \post_edit, {post:p?[0]}
    $e = $ sel
    $e .add-class \editing
    $e .find('input[type="text"]').focus!

@align-breadcrumb = ->
  b = $ '.breadcrumb'
  m = $ '.menu'
  b.css \left ((m.width! - b.width!)/2 + m.offset!left)

# vim:fdm=indent
