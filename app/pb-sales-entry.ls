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
  $ \#register_top |> each -> $ it .css \top, "#{0-(offset*1.7)}px"
  $ \.stick        |> each -> $ it .css \top, "#{0-(offset*0.75)}px"

# focus!
set-timeout (-> $ \.SiteRegister-subdomain:first .focus!), 100ms
# vim:fdm=marker
