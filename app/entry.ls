
# XXX client-side entry for homepage/forum mutants

# shortcuts
$w = $ window
$d = $ document

#{{{ Waypoints
$w.resize -> set-timeout (-> $.waypoints \refresh), 800
set-timeout (-> # sort control
  $ '#sort li' .waypoint {
    context: \ul
    offset : 30
    handler: (direction) ->
      e = $ this # figure active element
      if direction is \up
        e := e.prev!
      e := $ this unless e.length

      $ '#sort li.active' .remove-class \active
      e .add-class \active # set!
  }), 100
#}}}
#{{{ Main Menu
$d.on \click 'html.homepage header .menu a.title' ->
  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html.forum header .menu a.title' window.mutate
#}}}

# main
# ---------
add-post-dialog = ->
  query =
    fid: window.active-forum-id
    pid: window.active-post-id

  html <- $.get '/resources/posts', query
  $(html).dialog modal: true
  false # stop event propagation

# assumes immediate parent is form (in case of submit button)
add-post = ->
  form = $ '#add-post-form'
  $.post '/resources/posts', form.serialize!, (_r1, res) ->
    console.log 'success! post added', res
    console.log 'stub: do something fancy to confirm submission'
  false # stop event propagation

# delegated events
$d.on \click '#add-post-submit' add-post
$d.on \click '.onclick-add-post-dialog' add-post-dialog

# vim:fdm=marker
