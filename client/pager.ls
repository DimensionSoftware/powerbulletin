define = window?define or require(\amdefine) module
require, exports, module <- define

{show-tooltip} = require \./client-helpers

/*

## An Experiment in Pagination

- It wants to fill all (or most) of the displayed height of the area its controlling.
- It should be relatively narrow.
- Clicking on it will change what page you're on.
  - The page number is calculated proportionally to the height of the pager relative to the number of pages.
- Hovering over it could provide info on what page you'll go to if you click there.
  - However, many touch devices are unable to hover.  What to do?
    http://ux.stackexchange.com/questions/970/what-are-some-alternatives-to-hover-on-touch-based-devices


- It has to work on the server side, too.

### HTML Structure

  #pager
    .first
    .current
    .last

*/

indicator-height = (pages, height) -> Math.floor(height / pages)

indicator-top = (page, i-height) -> (page - 1) * i-height

page-from-click-height = (click-height, i-height) ->
  f = Math.ceil(click-height / i-height)
  if f is 0
    1
  else
    f

module.exports = class Pager
  # Create a pager object
  # @param String id            (required) id of element containing pager
  # @param Object options
  #   @param Number last        (required) last page
  #   @param Number current     current page (defaults to 1)
  # @returns Object             the new pager
  (@id, options) ->
    @last     = options.last
    @current  = parse-int(options.current) or 1
    @forum-id = options.forum-id
    @$el      = $(@id)
    @init!

    # handlers
    @$el.click @on-click-set-page
    @$el.find(\.current).draggable({
      axis        : \y
      containment : \parent
      grid        : [0, @indicator-height]

      drag: (ev, ui) ~>
        page = page-from-click-height(ui.position.top + Math.floor(@indicator-height/2), @indicator-height)

      stop: (ev, ui) ~>
        page = page-from-click-height(ui.position.top + Math.floor(@indicator-height/2), @indicator-height)
        # hack to get around jQuery UI bug that doesn't honor the containment
        @set-page page
    })
    @$el.find('a.previous').click (ev) ~>
      @previous-page!
      ev.prevent-default!
      return false
    @$el.find('a.next').click (ev) ~>
      @next-page!
      ev.prevent-default!
      return false
    $(window).resize @on-resize-re-init

  # Reconfigure an existing pager.  This is usually used when page mutations happen.
  init: ->
    $ \body .toggle-class \paginator (@last > 1) # only show if multiple pages
    @height = @$el.height!
    @indicator-height = indicator-height(@last, @height)
    try
      @$el.find \.current .draggable(\option, \grid, [0, @indicator-height])

  # thread uri for page n
  url-for-page: (n) ~>
    href = window.location.pathname
    base = href.replace /\/page\/.*$/, ''
    if n is 1
      base
    else
      "#base/page/#n"

  # Change the page to page n
  set-page: (n, use-history=true) ~>
    @current = if n > @last then @last else n
    @$el.find \.current
      .css(top: indicator-top(@current, @indicator-height), height: @indicator-height)
    History.push-state {surf-data: window.surf-data}, '', @url-for-page(@current) if use-history
    @set-next-and-previous-links!
    # tooltip
    t = @$el.find \.tooltip
    show-tooltip t, "Page #{@current}"

  # Change to the next page
  next-page: ~>
    if @current < @last
      @set-page parse-int(@current)+1
    else
      return false

  # Change to the previous page
  previous-page: ~>
    if @current > 1
      @set-page @current-1
    else
      return false

  # next and prev urls
  set-next-and-previous-links: ~>
    @$el.find \a.previous .attr \href @url-for-page(@current - 1 || 1)
    @$el.find \a.next     .attr \href @url-for-page(Math.min(@last, parse-int(@current) + 1))
    switch @current
    | 1         =>
      @$el.find \a.page.previous .hide!
      @$el.find \a.page.next     .show!
    | @last     =>
      @$el.find \a.page.previous .show!
      @$el.find \a.page.next     .hide!
    | otherwise => @$el.find \a.page .show!

  #
  on-click-set-page: (ev) ~>
    window.ev = ev
    y = (ev, $el) ->
      dy = ev.page-y - parse-int($el.css('padding-top')) - $el.offset!top
      if dy < 0
        0
      else if dy > $el.height!
        $el.height!
      else
        dy
    dy = y(ev, @$el)
    page = page-from-click-height(dy, @indicator-height)
    @set-page page

  #
  on-resize-re-init: (ev) ~>
    @init!
    @set-page @current, false


Pager.indicator-height       = indicator-height
Pager.indicator-top          = indicator-top
Pager.page-from-click-height = page-from-click-height
