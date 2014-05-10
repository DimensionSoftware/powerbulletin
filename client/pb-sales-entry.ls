define = window?define or require(\amdefine) module
require, exports, module <- define

require! $R:reactivejs

require! {
  \../component/Sales
  \../component/Buy
}

# legacy
require \jqueryHistory
require \jqueryTransit
require \jqueryUi
require \jqueryWaypoints
{partition} = require \prelude-ls

# components
#{{{ components
window.component =
  sales: (new Sales {-auto-render} \body).attach!

window.do-buy = ->
  window.component.buy ||= (new Buy).attach!
  <- lazy-load-fancybox
  $.fancybox(window.component.buy.$)

#}}}

# "global" window/layout behaviors below
focus-last  = -> set-timeout (-> $ \.SiteRegister-subdomain:last .focus!), 300ms
focus-first = -> set-timeout (-> $ \.SiteRegister-subdomain:first .focus!), 300ms
cur-id      = void # waypoint id of current scrolled-to-section

# focus events
$ '#products .onclick-scroll-to' .click -> focus-last!

#{{{ parallax
# shim layer with setTimeout fallback
window.request-anim-frame = (->
  window.requestAnimationFrame       or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame    or
  window.oRequestAnimationFrame      or
  window.msRequestAnimationFrame     or
  (cb) ->
    window.set-timeout cb, 1000 / 60)!

dir           = \down
last-id       = void
last-visible  = []
last-scroll-y = window.scroll-y
$w            = $ window
bh            = $ \body .height!
ticking       = false

update-elements = ->
  offset  = $w.scroll-top!
  if offset is 0 then focus-first!
  if Math.abs(bh - (offset + $w.height!)) < 15px then focus-last! # within 15px of bottom so dom doesn't jerk

  # top animations
  if offset < 530px # save cpu for top pieces
    $ \#imagine .css {y:"#{0+(offset*0.5)}px"}

  if offset > 40px
    # move background images in view
    const all = <[.first .second .third .fifth]>
    # <optimization> -- save work on invisible sections & by knowing scroll direction
    if cur-id
      last-dir = dir
      if last-scroll-y < window.scroll-y then dir := \down
      if last-scroll-y > window.scroll-y then dir := \up
      if (last-dir isnt dir) or (last-id isnt cur-id) # new section in view, so-- show & hide
        if dir is \down
          cur = switch cur-id # given cur-id, these must be visible:
          | \features   => <[.first]>
          | \navigation => <[.second .first]>
          | \responsive => <[.third .second .first]>
          | \realtime   => <[.fifth .third .second]>
          #| \products   => <[.third .fifth]>
          | \support    => <[.fifth .third]>
        else # upward direction
          cur = switch cur-id # given cur-id, these must be visible:
          | \features   => <[.first]>
          | \navigation => <[.first .second]>
          | \responsive => <[.first .second .third]>
          | \realtime   => <[.second .third .fifth]>
          #| \products   => <[.third .fifth]>
          | \support    => <[.third .fifth]>

        [visible, hide] = partition (-> it in cur), all
        for h in hide then $ h .remove-class \visible # hide these
        for v in visible then $ v .add-class \visible # show these
        last-id      := cur-id
        last-visible := visible
      else # same section, so parallax visible sections!
        for v in last-visible
          dy = -($ v .offset!?top)
          $ "#v .bg" .transition {y:"#{parse-int (dy+offset)*0.65}px"}, 0

  last-scroll-y := window.scroll-y
  ticking       := false

on-resize = -> update-elements window.scroll-y
on-scroll = (ev) ->
  unless ticking
    ticking := true
    requestAnimFrame updateElements

# listen & go!
window.add-event-listener \resize, on-resize, false
window.add-event-listener \scroll, on-scroll, false
#}}}
#{{{ waypoints
fn = (direction) ->
  id  = this.id or ($ this .attr \id)
  cur = ($ \nav .find \.active).attr \class
  if cur is id then return # guard
  $ \nav # activate right-side bullets
    ..find \.active .remove-class \active # remove
    ..find ".#id" .add-class \active
  #$ \.shown .remove-class \shown # reset
  $ "##{id}" .add-class \shown
  cur-id := id # track

# - on scroll
$ '#features, .feature' .waypoint fn, {offset: 600px}
# - on click
$ 'nav a' .on \click ->
  id = ($ this .parents \li:first).attr \class
  set-timeout (~> fn.call {id}), 700ms # force correct selection
  if id is \support then focus-last!

set-timeout (-> $ \.shown .not(\#support).remove-class \shown), 600ms # reset if had to scroll-to-top
#}}}
#{{{ setup reactive user before layout kicks off
window.r-user = $R((user) ->
  if user
    component.sales.login user
  else
    component.sales.logout!
)
#}}}
<- require [\./layout]

# register action
# get the user after a successful login
Auth.after-login = ->
  window.user <- $.getJSON \/auth/user
  if window.r-user then window.r-user window.user
  onload-personalize!
  socket?disconnect!
  socket?socket?connect!
# vim:fdm=marker
