define = window?define or require(\amdefine) module
require, exports, module <- define

require! $R:reactivejs

#{{{ setup reactive user before layout kicks off
window.r-user = $R((user) ->
  if user
    component.sales.login user
  else
    component.sales.logout!
)
#}}}

require! {
  \../component/Sales
  \../component/SalesRouter
  \../component/Buy
}

# legacy
require \jqueryHistory
require \jqueryTransit
require \jqueryUi
require \./layout
require \jqueryWaypoints
{each} = require \prelude-ls

# components
window.router = new SalesRouter
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
$ window .on \scroll, ->
  offset  = $ window .scroll-top!
  if offset is 0 then focus-first!

  # top animations
  if offset < 430px # save cpu for top pieces
    $ \#imagine .css {y:"#{0+(offset*0.65)}px"}

  # move background images in view
  cur = switch cur-id
  | \features   => <[.first .second]>
  | \navigation => <[.first .second .third]>
  | \responsive => <[.first .second .third .fourth]>
  | \realtime   => <[.second .third .fourth .fifth]>
  | \products   => <[.third .fourth .fifth]>
  | \support    => <[.third .fourth .fifth]>
  if cur then for e in cur
    dy = -($ e .offset!?top)
    $ "#e .bg" .css \y, "#{0+((dy+offset)*0.6)}px"
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

# vim:fdm=marker
