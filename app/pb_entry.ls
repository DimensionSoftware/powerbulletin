window.__  = require \lodash
window.ioc = require './io_client'

global <<< require './pb_helpers'

# XXX client-side entry

# shortcuts
$w = $ window
$d = $ document

#{{{ UI Interactions
# ui save state
sep    = \-
offset = 20px
window.save-ui = -> # serealize ui state to cookie
  min-width = 200px
  w = $ '#left_content' .width!
  s = ($.cookie \s)
  if s then [_, _, prev] = s.split sep
  w = if w > min-width then w else prev or min-width # default
  vals =
    if $ \body .has-class(\searching) then 1 else 0
    if $ \body .has-class(\collapsed) then 1 else 0
    w
  $.cookie \s, vals.join(sep),
    path: '/'
window.load-ui = -> # restore ui state from cookie
  s  = ($.cookie \s)
  $l = $ '#left_content'
  if s
    [searching, collapsed, w] = s.split sep
    w = parseInt w
    $l.transition({width:w}, 500ms, \easeOutExpo -> # restore
      #$ \footer .css \left $l.width!                # ..footer
      $l.toggle-class \wide ($l.width! > 300px))    # ..left nav
    set-timeout (-> # ... & snap
      $ '#main_content.container .forum' .transition({padding-left:w + 20px}, 450ms, \snap)), 200ms
  if searching is not '0' then $ \body .add-class(\searching)
  if collapsed is not '0' then $ \body .add-class(\collapsed)
  set-timeout align-breadcrumb, 500ms

# handle
$d.on \click '#handle' ->
  $l = $ '#left_content'
  $ \body .toggle-class \collapsed
  #$ \footer .css \left $l.width!  # ..footer
  $ '#main_content.container .forum'
    .css('padding-left', ($l.width! + offset))
  save-ui!

# waypoints
$w.resize -> set-timeout (-> $.waypoints \refresh), 800ms
set-timeout (-> # sort control
  $ '#sort li' .waypoint {
    context: \ul
    offset : 30px
    handler: (direction) ->
      e = $ this # figure active element
      if direction is \up
        e := e.prev!
      e := $ this unless e.length

      $ '#sort li.active' .remove-class \active
      e .add-class \active # set!
  }), 100ms

# main menu
$d.on \click 'html.homepage header .menu a.title' ->
  awesome-scroll-to $(this).data \scroll-to; false
$d.on \click 'html.forum header .menu a.title' window.mutate

# header expansion
$d.on \click 'header' (e) ->
  $ \body .remove-class \searching if e.target.class-name.index-of(\toggler) > -1 # guard
  $ '#query' .focus!
  save-ui!
$d.on \keypress '#query' -> $ \body .add-class \searching; save-ui!

# show reply ui
append-reply-ui = ->
  # find post div
  $p = $ this .parents('.subpost:first')
  $p = $ this .parents('.post:first') unless $p.length

  # append dom for reply ui
  unless $p.find('.post-edit:visible').length
    render-and-append window,  $p.find('.reply:first'), \post_edit, (post:
      method:     \post
      forum_id:   active-forum-id
      parent_id:  $p.data 'post-id'
      is_comment: true), ->
        $p.find('textarea[name="body"]').focus!
  else
    $p.find('.cancel').click!

censor = ->
  # find post div
  $subpost = $(this).parents('.subpost:first')
  unless $subpost.length
    $subpost = $(this).parents('.post:first')
  post-id  = $subpost.data('post-id')

  $.post "/resources/posts/#{post-id}/censor", (r) ->
    if r.success
      $subpost.transition { opacity: 0, scale: 0.3 }, 300s, 'in', ->
        $subpost.hide!
    else
      console.warn r.errors.join(', ')
#}}}

#.
#### main   ###############>======-- -   -
##
if window.location.hash is '#validate' then after-login! # email activation
load-ui!
$ '#query' .focus!

#{{{ Delegated Events
# generic form-handling ui
$d.on \click '.create .no-surf' require-login(->
  $ '#main_content .forum' .html '' # clear canvas
  edit-post is-editing!, forum_id:window.active-forum-id)
$d.on \click '.edit.no-surf' require-login(-> edit-post is-editing!)
$d.on \click '.onclick-submit .cancel' ->
  f = $ this .closest '.post-edit'  # form
  f.hide 350ms \easeOutExpo
  remove-editing-url!
$d.on \click '.onclick-submit input[type="submit"]' require-login(
  (e) -> submit-form(e, (data) ->
    f = $ this .closest('.post-edit') # form
    p = f .closest('.editing')        # post being edited
    # render updated post
    p.find '.title' .html(data.0?title)
    p.find '.body'  .html(data.0?body)
    f.remove-class \fadein .hide(300s) # & hide
    remove-editing-url!
    false))

$d.on \click '.onclick-append-reply-ui' require-login(append-reply-ui)
$d.on \click '.onclick-censor-post' require-login(censor)

# login delegated events
window.switch-and-focus = (remove, add, focus-on) ->
  $e = $ '.fancybox-wrap'
  $e .remove-class("#{remove} shake slide").add-class(add)
  setTimeout (-> $e.add-class \slide; $ focus-on .focus! ), 10ms
$d.on \click '.onclick-close' ->
  $.fancybox.close!
$d.on \click '.onclick-show-login' ->
  switch-and-focus 'on-forgot on-register' \on-login '#auth input[name=username]'
$d.on \click '.onclick-show-forgot' ->
  switch-and-focus \on-error \on-forgot '#auth input[name=email]'
$d.on \click '.onclick-show-choose' ->
  switch-and-focus \on-login \on-choose '#auth input[name=username]'
$d.on \click '.onclick-show-register' ->
  switch-and-focus \on-login \on-register '#auth input[name=username]'

# catch esc key events on input boxes for login box
$d.on \keyup '.fancybox-inner input' ->
  if it.which is 27 # enter key
    $.fancybox.close!
    return false
#}}}
#{{{ Infinity JS
at-bottom = (pct-threshold = 0.7) ->
  # thx, stack overflow guy:
  # http://stackoverflow.com/a/12279215
  # I super distilled it though... and added a threshold
  # and... more heuristics
  [st, wh, dh] = [$w.scroll-top!, $w.height!, $d.height!]

  # represents roughly the percentage scrolled down in window
  rough-scroll-percent = (wh + st) / dh

  # additional debug annotations
  #console.log {st, wh, dh}
  #console.log {wh-plus-st: wh + st, rough-scroll-percent}

  # Not at the top of the page
  #      | We're definitely at the end, motherfucker
  #      |                   |     
  #      |                   | Alternatively, the boss (programmer) said we are at the end, motherfucker
  #      |                   |                                         |
  #      \/                  \/                                        \/
  (st > 0) && ((wh + st >= dh) || (rough-scroll-percent > pct-threshold))

# infinity scroll -- function to add placeholders divs for pages
# TODO: calculate actual number of pages to be appended (there is a max)
infinity-load-more-placeholders = ->
  if window.lv and window.page < window.pages-count
    window.page = window.page + 1 # increment page for next operation
    el = window.lv.append "<div data-page=\"#{window.page}\"/>"

toggle-page = (num) ->
  $ '#paginator .page' .remove-class \active
  $ "\#paginator .page:contains(#{num})" .add-class \active

track-pages = ->
  current-top = $w.scroll-top!
  pages = []

  $('[data-page]').each ->
    $el = $(this)
    top = $el.position!.top
    dist = Math.abs(top - current-top)
    pages.push {$el, top, dist}

  # choose page with lowest 
  if pages.length
    closest = pages.reduce (p1, p2) ->
      if p1.dist > p2.dist
        p2
      else
        p1

    cur-page = closest.$el.data \page
    toggle-page cur-page

#track-pages = ->
  # tops is the list of tops for
  # beppus fun: c is current position
  #function page(c, tops) { return 1 + tops.indexOf(__.find(tops, function(t){ return t > c })) }

$(window).scroll __.debounce((-> if at-bottom! then infinity-load-more-placeholders!), 25ms)
$(window).scroll __.debounce(track-pages, 100ms)

$d.on \click, '#paginator a.page', ->
  target-page = parse-int $(this).text!

  # load at most this many extra placeholders, since there are already some loaded
  for p in [window.page to target-page]
    infinity-load-more-placeholders!

  set-timeout (-> awesome-scroll-to("[data-page=#{target-page}]")), 100ms
#}}}

window.has-mutated-forum = window.active-forum-id

if mocha? and window.location.search.match /test=1/
  mocha.setup \bdd
  $.get-script '//muscache5.pb.com/tests/test1.js', mocha.run

# vim:fdm=marker
