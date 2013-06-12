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
    if beg < page-distance
      # len needs to be increased
      end += page-distance - beg
      end = Math.min(page-qty, end) # don't overshoot actual page-qty

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

    ({@pnum-to-href} = {}) ->
      @pnum-to-href ||= (-> "?page=#it")
      super ...

    init: ->
      for k,v of default-locals when @local(k) is void
        @local k, v

      @calculate!

    component-name: \Paginator
    template: templates.Paginator
    calculate: !->
      locals = @locals!
      for k, v of calc(locals, @pnum-to-href)
        @local k, v
