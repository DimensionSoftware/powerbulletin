
# XXX shared by pb_mutants & pb_entry

# double-buffered replace of view with target
@insert-dom = (w, target, tmpl, params) ->
  $t = w.$ target
  $b = w.$ "<div class='container'>"
  $b.hide!
  $t.prepend $b
  jade.render $b[0], tmpl, params
  $b.show!add-class \fadein

@is-editing-regexp = /(edit|new)\/?([\d+]*)/

@is-editing = ->
  m = window.location.pathname.match @is-editing-regexp
  return if m then m[2] else false

@remove-editing-url = ->
  if window.location.href.match is-editing-regexp
    History.push-state {no-surf:true} '' window.location.href.replace(/\/edit\/[\/\d+]+$/, '')

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
  $e  = $ sel
  focus = -> $e.find('input[type="text"]').focus!
  unless $e.find('.container:first:visible').length # guard
    $.get "/resources/posts/#{id}" (p) ->
      insert-dom window, "#{sel}", \post_edit, {post:p?0}
      $e .add-class \editing
      focus!
  else
    focus!

@align-breadcrumb = ->
  b = $ '.breadcrumb'
  m = $ '.menu'
  b.css \left ((m.width! - b.width!)/2 + m.offset!left)

# vim:fdm=indent
