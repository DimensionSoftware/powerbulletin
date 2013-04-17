require! {
  furl: './forum_urls'
}

# XXX shared by pb_mutants & pb_entry

@set-online-user = (id) ->
  $ "[data-user-id=#{id}] .profile.photo" .add-class \online

# double-buffered replace of view with target
@render-and = (fn, w, target, tmpl, params, cb) -->
  $t = w.$ target  # target
  $b = w.$ '<div>' # buffer
  $b.hide!
  $t[fn] $b
  w.jade.render $b.0, tmpl, params
  $b.show!add-class \fadein
  set-timeout (-> cb $b), 100ms # XXX race condition
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
  switch meta.type
  | \edit       => History.push-state {no-surf:true} '' meta.thread-uri
  | \new-thread => History.back!

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
@edit-post = (id, data={}) ->
  focus  = (e) -> set-timeout (-> e.find 'input[type="text"]' .focus!), 100
  render = (sel, locals) ~>
    e = $ sel
    @render-and-append window, sel, \post_edit, post:locals, (e) ->
      e.find \.sceditor-container .prepend(e.find \.title)
      focus e

  if id is true # render new
    scroll-to-top!
    data.action = \/resources/post
    data.method = \post
    render \.forum, data
  else # fetch existing & render
    scroll-to-edit!
    console.log data
    sel = "\#post_#{id}"
    e   = $ sel
    unless e.find(\.container:first:visible).length # guard
      $.get "/resources/posts/#{id}" (p) ->
        render sel, p
        e .add-class \editing
    else
      focus e

  # init sceditor
  $ \textarea.body .sceditor(
    plugins:        \bbcode
    style:          "#{window.cache_url}/local/jquery.sceditor.default.min.css"
    toolbar:        'bold,italic,underline|image,link,youtube|emoticon|source'
    width:          \85%
    emoticons-root: "#{window.cache_url}/")

@align-breadcrumb = ->
  b = $ '#breadcrumb'
  m = $ '.menu'
  b.css \left ((m.width! - b.width!)/2 + m.offset!left)

# vim:fdm=indent
