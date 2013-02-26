
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
$ '#left_content' .resizable!
add-post-dialog = ->
  query =
    fid: window.active-forum-id

  html <- $.get '/resources/posts', query
  $(html).dialog modal: true
  false # stop event propagation

# assumes immediate parent is form (in case of submit button)
add-post = ->
  form = $ '#add-post-form'
  $.post '/resources/posts', form.serialize!, (_r1, _r2, res) ->
    console.log 'success! post added', res
    console.log 'stub: do something fancy to confirm submission'
  false # stop event propagation

# show reply ui
append-reply-ui = ->
  # find post div
  $subpost = $(this).parents('.subpost:first')
  post-id  = $subpost.data('post-id')

  # FIXME html 
  reply-ui-html = """
  <form method="post" action="/resources/posts">
    <textarea name="body"></textarea>
    <input type="hidden" name="forum_id" value="#{window.active-forum-id}">
    <input type="hidden" name="parent_id" value="#{post-id}">
    <div>
      <input type="submit" value="Post">
    </div>
  </form>
  """
  # append dom for reply ui
  if $subpost.find('.reply form').length is 0
    $subpost.find('.reply:first').append reply-ui-html
  else
    $subpost.find('.reply:first form').remove!

#
show-login-dialog = ->
  $.fancybox.open '#auth'

# login action
login = ->
  $form = $(this)
  params =
    username: $form.find('input[name=username]').val!
    password: $form.find('input[name=password]').val!
  $.post $form.attr(\action), params, (r) ->
    if r.success
      window.location.reload!
      # XXX - need to make this not require a reload
      # window.user = r.user
      # XXX - then emit an event to let various client-side systems know that we're logged in now
    else
      $fancybox = $form.parents('.fancybox-wrap:first')
      $fancybox.remove-class \shake
      set-timeout (-> $fancybox.add-class(\shake)), 100
  return false

# require that window.user exists before calling fn
require-login = (fn) ->
  ->
    if window.user
      fn.apply this, arguments
    else
      show-login-dialog!
      false

# delegated events
$d.on \click '#add-post-submit' require-login(add-post)
$d.on \click '.onclick-add-post-dialog' add-post-dialog

$d.on \click '.onclick-append-reply-ui' append-reply-ui

$d.on \submit '.login form' login

# personalization ( based on parameters from user obj )
user <- $.getJSON '/auth/user'

#{{{ Mutant init
window.mutant  = require '../lib/mutant/mutant'
window.mutants = require './mutants'
window.mutate  = (e) ->
  href = $ this .attr \href
  return false unless href # guard
  return true if href?.match /#/
  search-params = {}
  History.push-state {search-params}, '', href
  false

#XXX: needs more friendly api-like way to handle this case with mutant
on-load = window.mutants[window.mutator]?.on-load or (window, next) -> next!
on-personalize = window.mutants[window.mutator]?.on-personalize or (w, u, next) -> next!
<- on-load.call this, window # fire on-load of initial mutant
<- on-personalize.call this, user, window # fire on-load of personalize mutant
$ '#query' .focus!

$d.on \click 'a.mutant' window.mutate # hijack urls

History.Adapter.bind window, \statechange, (e) -> # history manipulaton
  url = History.get-page-url!replace /\/$/, ''
  $.get url, _surf:1, (r) ->
    $d.attr \title, r.locals.title if r.locals?.title # set title
    on-unload = window.mutants[window.mutator].on-unload or (w, cb) -> cb null
    on-unload window, -> # cleanup & run next mutant
      try
        window.mutant.run window.mutants[r.mutant], {locals:r.locals, user}
      catch e
        # do nothing
  return false

#}}}

# vim:fdm=marker
#
# XXX layout-specific client-side

# shortcuts
$w = $ window
$d = $ document

is-ie     = false or \msTransform in document.documentElement.style
is-moz    = false or \MozBoxSizing in document.documentElement.style
is-opera  = !!(window.opera and window.opera.version)
threshold = 10 # snap

# main
# ---------
#{{{ Scrolling behaviors
window.scroll-to-top = ->
  return if ($ window).scroll-top! is 0 # guard
  $e = $ 'html,body'
  <- $e .animate { scroll-top:$ \body .offset!top }, 140
  <- $e .animate { scroll-top:$ \body .offset!top+threshold }, 110
  <- $e .animate { scroll-top:$ \body .offset!top }, 75

# indicate to stylus that view scrolled
has-scrolled = ->
  st = $w.scrollTop!
  $ \body .toggle-class 'scrolled' (st > threshold)
set-timeout (->
  $w.on \scroll -> has-scrolled!
  has-scrolled!), 1300 # initially yield

window.awesome-scroll-to = (e, duration, on-complete) ->
  on-complete = -> noop=1 unless on-complete

  e     := $ e
  ms     = duration or 600
  offset = 100

  return unless e.length # guard
  if is-ie or is-opera
    e[0].scroll-into-view!
    on-complete!
  else # animate
    dst-scroll = Math.round(e.position!top) - offset
    cur-scroll = window.scrollY
    if Math.abs(dst-scroll - cur-scroll) > 30
      #<- $ 'html,body' .animate { scroll-top:dst-scroll }, 140
      #<- $ 'html,body' .animate { scroll-top:dst-scroll+threshold }, 110
      <- $ 'html,body' .animate { scroll-top:dst-scroll }, ms
    else
      on-complete!
  e

# attach scroll-to's
$d.on \click '.scroll-to' ->
  awesome-scroll-to $(this).data \scroll-to
  false

# attach scroll-to-top's
$d.on \mousedown '.scroll-to-top' ->
  $ this .attr \title 'Scroll to Top!'
  window.scroll-to-top!
  false
#}}}

# header expansion
$d.on \click 'header' (e) ->
  $ \body .remove-class \expanded if e.target.class-name.index-of(\toggler) > -1 # guard
  $ '#query' .focus!
$d.on \keypress '#query' -> $ \body .add-class \expanded


# vim:fdm=marker
