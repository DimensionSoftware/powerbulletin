require! $R:reactivejs
require! {
  \../component/SalesApp
  \../component/Buy
}
global <<< require(\prelude-ls/prelude-browser-min) \prelude-ls

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
  if offset < 500px # save cpu for top pieces
    inverse = 8/Math.abs(offset+0.01)
    $ \#imagine      .css \opacity, inverse
    $ \#logo         .css {opacity:50/Math.abs(offset), y:"#{0-(offset*0.3)}px"}
    $ \#register_top .css {opacity:inverse, y:"#{0-(offset*2.7)}px"}

  $ \.bg    |> each -> $ it .css \y, "#{0-(offset*0.3)}px"
  $ \.stick |> each -> $ it .css \y, "#{0-(offset*1.3)}px"
    #$ \.stick:even |> each -> $ it .css \y, "#{0-(offset*0.75)}px"
    #$ \.bg:first .css \opacity, 300/Math.abs(offset+0.01)

# animate focus
set-timeout (->   # bring in register
  $ \.logo-icon    .transition {opacity:1, x:\-25px, y:\-25px, rotate:\0deg}, 700ms, \easeOutExpo
  $ \#register_top .transition {x:25px, opacity:1}, 1000ms, \easeOutExpo
  $ \.SiteRegister-subdomain:first .focus!
  set-timeout (-> # ...and action!
    $ '.SiteRegister h3' .transition {opacity:1, y:30px}, 400ms), 100ms), 300ms

unless $ window .scroll-top is 0 # scroll to top
  $ 'html,body' .animate {scroll-top:0}, 500ms, \easeOutExpo

# vim:fdm=marker
