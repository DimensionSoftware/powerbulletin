require! {
  \../component/SalesApp.ls
  \../component/Buy.ls
}

# components
window.component =
  sales-app = (new SalesApp {-auto-render} \body).attach!

window.do-buy = ->
  window.component.buy ||= (new Buy).attach!
  $.fancybox(window.component.buy.$)
# vim:fdm=marker
