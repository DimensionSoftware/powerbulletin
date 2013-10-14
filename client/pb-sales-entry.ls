define = window?define or require(\amdefine) module
require, exports, module <- define

require! $R:reactivejs
require! {
  \../component/SalesApp
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

focus-last  = -> set-timeout (-> $ \.SiteRegister-subdomain:last .focus!), 500ms
focus-first = -> set-timeout (-> $ \.SiteRegister-subdomain:first .focus!), 500ms
cur-id      = void # waypoint id of current scrolled-to-section

# focus events
$ '#products .onclick-scroll-to' .click -> focus-last!

#{{{ components
window.component =
  sales-app: (new SalesApp {-auto-render} \body).attach!

window.do-buy = ->
  window.component.buy ||= (new Buy).attach!
  <- lazy-load-fancybox
  $.fancybox(window.component.buy.$)

$R((user) ->
  if user
    component.sales-app.login user
  else
    component.sales-app.logout!
).bind-to window.r-user
#}}}
#{{{ parallax
$ window .on \scroll, ->
  offset  = $ window .scroll-top!
  if offset is 0 then focus-first!

  # top animations
  if offset < 430px # save cpu for top pieces
    $ \#imagine .css {y:"#{0+(offset*0.45)}px"}

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
  cur-id := id # track

# - on scroll
$ '#features, .feature' .waypoint fn, {offset: 400px}
# - on click
$ 'nav a' .on \click ->
  id = ($ this .parents \li:first).attr \class
  set-timeout (~> fn.call {id}), 300ms # force correct selection
  if id is \support then focus-last!
#}}}
#{{{ animate build-in & initial focus
set-timeout (-> # bring in register
  icon = $ \.logo-icon
  icon.transition {opacity:1, x:\0px, y:\0px, rotate:\0deg}, 700ms, \easeOutExpo
  $ \#register_top  .add-class \show
  focus-first!
  set-timeout (-> # ...and action!
    $ '.SiteRegister h3' .transition {opacity:1, y:30px}, 400ms
    icon.add-class \hover-around
    set-timeout (-> # build-in features last
      $ \#features .transition {opacity:1}, 1200ms), 1000ms), 100ms), 500ms

unless $ window .scroll-top is 0 # scroll to top
  $ 'html,body' .animate {scroll-top:0}, 300ms, \easeOutExpo
#}}}

# vim:fdm=marker
