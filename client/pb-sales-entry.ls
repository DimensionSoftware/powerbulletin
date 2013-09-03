define = window?define or require(\amdefine) module
require, exports, module <- define

require! $R:reactivejs
require! {
  \../component/SalesApp
  \../component/Buy
}

# legacy
require \jqueryHistory
require \jqueryTransit
require \jqueryUi
require \./layout
{each} = require \prelude-ls

# components
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

# parallax
$ window .on \scroll, ->
  offset  = $ window .scroll-top!
  # top animations
  if offset < 500px # save cpu for top pieces
    inverse = 8/Math.abs(offset+0.01)
    $ \#imagine      .css \opacity, inverse
    $ \#logo         .css {opacity:50/Math.abs(offset), y:"#{0-(offset*0.3)}px"}
    $ \#register_top .css {opacity:inverse, y:"#{0-(offset*2.7)}px"}

  # backgrounds
  # - FIXME optimize by pre-computing & only moving imgs in view
  for e in <[.first .second .third .fourth .fifth]>
    dy = -($ e .offset!top)
    $ "#e .bg" .css \y, "#{0+((dy+offset)*0.35)}px"

# animate focus
set-timeout (->   # bring in register
  icon = $ \.logo-icon
  icon.transition {opacity:1, x:\0px, y:\0px, rotate:\0deg}, 700ms, \easeOutExpo
  $ \#register_top .transition {x:25px, opacity:1}, 1000ms, \easeOutExpo
  $ \.SiteRegister-subdomain:first .focus!
  set-timeout (-> # ...and action!
    $ '.SiteRegister h3' .transition {opacity:1, y:30px}, 400ms
    icon.add-class \hover-around), 100ms), 300ms

unless $ window .scroll-top is 0 # scroll to top
  $ 'html,body' .animate {scroll-top:0}, 500ms, \easeOutExpo

# vim:fdm=marker
