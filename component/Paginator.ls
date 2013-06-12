require! \./Component.ls

{templates} = require \../build/component-jade.js

function calc-pages active-page, step, qty, page-distance, page-qty, pnum-to-href
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
    if beg < page-distance
      # len needs to be increased
      end += page-distance - beg
      end = Math.min(page-qty, end) # don't overshoot actual page-qty

  pages =
    for num in [beg to end]
      {title: num, href: pnum-to-href(num), active: parse-int(active-page) is num}

  if pages.length and pages.0.title isnt 1
    pages.unshift {title: 'first', href: pnum-to-href(1)}

  if pages.length and pages[pages.length - 1].title isnt page-qty
    pages.push {title: 'last', href: pnum-to-href(page-qty)}

  pages

module.exports =
  class Paginator extends Component
    default-locals =
      active-page: 1
      step: 8
      qty: 0
      # how many other pages behind and in front of active-page should we show?
      page-distance: 4

    ({@pnum-to-href} = {}) ->
      @pnum-to-href ||= (-> "?page=#it")
      super ...

    init: ->
      for k,v of default-locals when @local(k) is void
        @local k, v

      @state.page-qty = @@$R(
        (qty, step) -> Math.ceil(qty / step)
      ).bind-to @state.qty, @state.step

      @state.pages = @@$R(
        (...args) ~> calc-pages ...(args ++ @pnum-to-href)
      ).bind-to @state.active-page, @state.step, @state.qty, @state.page-distance, @state.page-qty
    component-name: \Paginator
    template: templates.Paginator
