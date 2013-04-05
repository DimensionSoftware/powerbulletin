require! {
  furl: './forum_urls'
}

# XXX shared by pb_mutants & pb_entry

# double-buffered replace of view with target
@render-and = (fn, w, target, tmpl, params, cb) -->
  $t = w.$ target  # target
  $b = w.$ '<div>' # buffer
  $b.hide!
  $t[fn] $b
  jade.render $b.0, tmpl, params
  $b.show!add-class \fadein
  cb $b
@render-and-append  = @render-and \append
@render-and-prepend = @render-and \prepend

@is-editing = (path) ->
  meta = furl.parse path
  switch meta.type
  | \new-thread => true
  | \edit       => meta.id
  | otherwise   => false

@remove-editing-url = ->
  meta = furl.parse window.location.pathname
  if meta.type is \edit
    History.push-state {no-surf:true} '' meta.thread-uri

@scroll-to-edit = (cb) ->
  cb = -> noop=1 unless cb
  id = is-editing window.location.pathname
  if id then # scroll to id
    awesome-scroll-to "\#post_#{id}" 600ms cb
    true
  else
    scroll-to-top cb
    false

# handle in-line editing
@edit-post = (id, data) ->
  console.log \edit-post
  focus  = (e) -> set-timeout (-> e.find 'input[type="text"]' .focus!), 100
  render = (sel, locals) ~>
    console.log sel
    e = $ sel
    @render-and-append window, sel, \post_edit, post:locals, ->
      focus e

  scroll-to-edit!
  if not id.length and data # render new
    data.action = '/resources/post'
    data.method = \post
    render '.forum', data
  else # fetch existing & render
    console.log data
    sel = "\#post_#{id}"
    e   = $ sel
    unless e.find('.container:first:visible').length # guard
      $.get "/resources/posts/#{id}" (p) ->
        render sel, p
        e .add-class \editing
    else
      focus e

@align-breadcrumb = ->
  b = $ '#breadcrumb'
  m = $ '.menu'
  b.css \left ((m.width! - b.width!)/2 + m.offset!left)

# vim:fdm=indent
