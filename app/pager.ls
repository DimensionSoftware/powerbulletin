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
    @current  = options.current or 1
    @forum-id = options.forum-id
    @$el      = $(@id)
    @init!

    # handlers
    @$el.click @on-click-set-page
    $(window).resize @on-resize-re-init


  # thread uri for page n
  url-for-page: (n) ~>
    href = window.location.pathname
    base = href.replace /\/page\/.*$/, ''
    if n is 1
      base
    else
      "#base/page/#n"

  # Change the page to page n
  set-page: (n) ~>
    @current = n
    @$el.find('.current')
      .text(n)
      .css(top: indicator-top(n, @indicator-height), height: @indicator-height)
    History.push-state {surf-data: @forum-id}, '', @url-for-page(n)

  # Reconfigure an existing pager with new options.  This is usually used when page mutations happen.
  # @param Object pager
  # @param Object options
  init: ->
    if @last > 1 then @$el.show! else @$el.hide! # only show if pages exist
    @height = @$el.height!
    #@height = @$el.height! - parseInt(@$el.css('padding-top')) - parseInt(@$el.css('padding-bottom'))
    @indicator-height = indicator-height(@last, @height)
    #@indicator-positions = scan (+ @indicator-height), 0, [1 to @last-1]

  #
  on-click-set-page: (ev) ~>
    window.ev = ev
    y = (ev, $el) ->
      dy = ev.page-y - parseInt($el.css('padding-top')) - $el.offset!top
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

