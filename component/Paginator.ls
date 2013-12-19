define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

function calc-pages active-page, step, qty, page-distance, page-qty, pnum-to-href
  active-page = parse-int active-page
  step = parse-int step
  qty = parse-int qty
  page-distance = parse-int page-distance
  page-qty = parse-int page-qty
  active-page = parse-int active-page

  beg = Math.max(active-page - page-distance, 1)
  end = Math.min(active-page + page-distance, page-qty)

  if active-page <= page-distance # near beg
    end = Math.min(end + (page-distance - active-page) + 1, page-qty)
  else if active-page >= (page-qty - page-distance) # near end
    beg = Math.max(beg - (page-distance - (page-qty - active-page)), 1)

  pages =
    for num in [beg to end]
      {num, title: num, href: pnum-to-href(num), active: active-page is num}

  first-page = pages.0
  last-page = pages[pages.length - 1]
  # move left anchor
  if page-qty and active-page > 1
    do ->
      num = active-page - 1
      pages.unshift {num, title: \<, href: pnum-to-href(num), class:\inset}

    # jump to first anchor
    pages.unshift {num: 1, title: \First, href: pnum-to-href(1)}

  # move right anchor
  if page-qty and active-page < page-qty
    do ->
      num = active-page + 1
      pages.push {num, title: \>, href: pnum-to-href(num), class:\inset}

    # jump to last anchor
    pages.push {num: page-qty, title: \Last, href: pnum-to-href(page-qty)}

  pages

module.exports =
  class Paginator extends PBComponent
    default-locals =
      active-page: 1
      step: 8
      qty: 0
      # how many other pages behind and in front of active-page should we show?
      page-distance: 4

    ({pnum-to-href, @on-page} = {}) ->
      unless pnum-to-href
        if @on-page
          pnum-to-href = (-> \#) # click handlers are used instead of urls
        else
          pnum-to-href = (-> "?page=#it")
      @pnum-to-href = @@$R.state pnum-to-href
      super ...

    init: ->
      for k,v of default-locals when @local(k) is void
        @local k, v

      @state.page-qty = @@$R((qty, step) ->
        Math.ceil(qty / step)
      ).bind-to @state.qty, @state.step

      do ~>
        bindings =
          * @state.active-page
          * @state.step
          * @state.qty
          * @state.page-distance
          * @state.page-qty
          * @pnum-to-href

        @state.pages = @@$R(calc-pages).bind-to ...bindings
    on-attach: ->
      @$.show!
      # attach optional click handlers
      if @on-page
        c = @
        handler = ->
          pg = parse-int @@$(@).data(\page)
          c.local \activePage, pg
          c.reload!
          c.on-page pg, c
          false # override default anchor behavior
        @$.on \click \a handler
    on-detach: -> @$.off!
