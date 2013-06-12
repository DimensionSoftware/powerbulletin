require! \./Component.ls

{templates} = require \../build/component-jade.js

function calc {active-page, step, qty, page-distance}, pnum-to-href
  page-qty = Math.ceil(qty / step)

  beg =
    if active-page > page-distance
      active-page - page-distance
    else
      1

  end =
    if active-page < (page-qty - page-distance)
      active-page + page-distance
    else
      page-qty

  min-len = page-distance * 2
  act-len = end - beg
  if act-len < min-len
    # len needs to be increased
    if beg < page-distance
      end += page-distance - beg
      console.log {end}
      end = Math.min(page-qty, end) # don't overshoot actual page-qty
      console.log {end}

  pages =
    for num in [beg to end]
      {title: num, href: pnum-to-href(num), active: active-page is num}

  if pages.length and pages.0.title isnt 1
    pages.unshift {title: 'first', href: pnum-to-href(1)}

  if pages.length and pages[pages.length - 1].title isnt page-qty
    pages.push {title: 'last', href: pnum-to-href(page-qty)}

  {page-qty, pages}

module.exports =
  class Paginator extends Component
    default-locals =
      active-page: 1
      step: 8
      qty: 0
      # how many other pages behind and in front of active-page should we show?
      page-distance: 4

    (opts, ...rest) ->
      opts ||= {}

      # overridable
      @pnum-to-href =
        opts.pnum-to-href or (-> "?page=#it")

      locals = {} <<< default-locals <<< opts.locals
      locals <<< @calculate locals
      opts <<< {locals}

      super opts, ...rest
    component-name: \Paginator
    template: templates.Paginator
    calculate: (override-locals) ->
      locals = override-locals or @locals!
      rval = {} <<< locals <<< calc(locals, @pnum-to-href)
      console.log rval
      rval

# REPL EXAMPLE:
# livescript> require! \./component/Paginator; p = new Paginator {locals: {qty:100}}; p.html!
# '<div class="Paginator"><strong class="Paginator-page"></strong><a href="?page=2" class="Paginator-page"></a><a href="?page=3" class="Paginator-page"></a><a href="?page=4" class="Paginator-page"></a><a href="?page=5" class="Paginator-page"></a><a href="?page=6" class="Paginator-page"></a><a href="?page=7" class="Paginator-page"></a><a href="?page=8" class="Paginator-page"></a><a href="?page=9" class="Paginator-page"></a><a href="?page=10" class="Paginator-page"></a><a href="?page=11" class="Paginator-page"></a><a href="?page=12" class="Paginator-page"></a><a href="?page=13" class="Paginator-page"></a><a href="?page=13" class="Paginator-page"></a></div>'
# require! \./component/Paginator; p = new Paginator {locals: {active-page:14, qty:100}}; p.html!
# '<div class="Paginator"><a href="?page=1" class="Paginator-page">first</a><a href="?page=10" class="Paginator-page">10</a><a href="?page=11" class="Paginator-page">11</a><a href="?page=12" class="Paginator-page">12</a><a href="?page=13" class="Paginator-page">13</a></div>'
