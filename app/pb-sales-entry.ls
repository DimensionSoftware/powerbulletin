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
  offset = $ window .scroll-top!
  $ \.logo         .css(\y, "#{0-(offset*0.06)}px")
  $ \#register_top .css(\y, "#{0-(offset*2.7)}px")
  $ \.stick:odd  |> each -> $ it .css \y, "#{0-(offset*0.8)}px"
  $ \.stick:even |> each -> $ it .css \y, "#{0-(offset*0.73)}px"

# focus!
set-timeout (->
  $ \#register_top .transition {x:25px, opacity:1}, 1000ms, \easeOutExpo
  $ \.SiteRegister-subdomain:first .focus!), 300ms
# vim:fdm=marker
