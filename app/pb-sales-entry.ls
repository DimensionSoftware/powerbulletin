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
  console.log \user, user
  if user
    component.sales-app.login user
  else
    component.sales-app.logout!
).bind-to window.r-user

# vim:fdm=marker
