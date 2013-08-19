require! $R:reactivejs
require! {
  \../component/SalesApp.ls
  \../component/Buy.ls
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
  inverse = 8/Math.abs(offset+0.01)
  if inverse < 0 then 0 else inverse
  $ \#imagine      .css \opacity, inverse
  $ \.logo         .css \y, "#{0-(offset*0.1)}px"
  $ \#register_top .css {opacity:inverse, y:"#{0-(offset*2.7)}px"}
  $ \.bg         |> each -> $ it .css \y, "#{0-(offset*0.68)}px"
  $ \.stick:odd  |> each -> $ it .css \y, "#{0-(offset*0.82)}px"
  $ \.stick:even |> each -> $ it .css \y, "#{0-(offset*0.77)}px"

# animate focus
set-timeout (->   # bring in register
  $ \#register_top .transition {x:25px, opacity:1}, 1000ms, \easeOutExpo
  $ \.SiteRegister-subdomain:first .focus!
  set-timeout (-> # ...and action!
    $ '.SiteRegister h3' .transition {opacity:1, y:30px}, 400ms), 100ms), 300ms

unless $ window .scroll-top is 0 # scroll to top
  $ 'html,body' .animate {scroll-top:0}, 500ms, \easeOutExpo

# vim:fdm=marker
