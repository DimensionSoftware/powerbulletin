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
focus-last  = -> set-timeout (-> $ \.SiteRegister-subdomain:last .focus!), 500ms
focus-first = -> set-timeout (-> $ \.SiteRegister-subdomain:first .focus!), 500ms
cur-id      = void # waypoint id of current scrolled-to-section

# focus events
$ '#products .onclick-scroll-to' .click -> focus-last!
#{{{ parallax
last=void
last-visible=[]
$w = $ window
bh = $ \body .height!
$w .on \scroll, (->
  offset  = $w.scroll-top!
  if offset is 0 then focus-first!
  if Math.abs(bh - (offset + $w.height!)) < 5px then focus-last!

  # top animations
  if offset < 430px # save cpu for top pieces
    $ \#imagine .css {y:"#{0+(offset*0.5)}px"}

  if offset > 40px
    # move background images in view
    const all = <[.first .second .third .fifth]>
    # <optimization> -- save work on invisible sections
    # TODO precompute jquery elements
    if cur-id
      if last isnt cur-id # new section in view, so-- show & hide
        cur = switch cur-id # given cur-id, these must be visible:
        | \features   => <[.first .second]>
        | \navigation => <[.first .second .third]>
        | \responsive => all
        | \realtime   => <[.second .third .fifth]>
        #| \products   => <[.third .fifth]>
        | \support    => <[.third .fifth]>
        [visible, hide] = partition (-> it in cur), all
        for h in hide then $ h .remove-class \visible # hide these
        for v in visible then $ v .add-class \visible # show these
        last         := cur-id
        last-visible := visible
      else # same section, so parallax visible sections!
        for v in last-visible
          dy = -($ v .offset!?top)
          $ "#v .bg" .transition {y:"#{parse-int (dy+offset)*0.65}px"}, 0)
#}}}
#{{{ waypoints
fn = (direction) ->
  id  = this.id or ($ this .attr \id)
  cur = ($ \nav .find \.active).attr \class
  if cur is id then return # guard
  $ \nav # activate right-side bullets
    ..find \.active .remove-class \active # remove
    ..find ".#id" .add-class \active
  $ "##{id}" .add-class \shown
  cur-id := id # track

# - on scroll
$ '#features, .feature' .waypoint fn, {offset: 600px}
# - on click
$ 'nav a' .on \click ->
  id = ($ this .parents \li:first).attr \class
  set-timeout (~> fn.call {id}), 300ms # force correct selection
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
