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


### PROBLEMS WITH MUTANT

  - DOM is prone to getting blasted away on mutate.
  - I need #paginator to stay in the DOM unmolested on mutate.


*/

indicator-height = (pages, height) -> Math.floor(height / pages)

indicator-top = (page, i-height) -> (page - 1) * i-height

page-from-click-height = (click-height, i-height) -> Math.floor(click-height / i-height)

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
      .css(top: indicator-top(n, @indicator-height), height: @indicator-height, line-height: @indicator-height - 8 + \px)
    History.push-state {surf-data: @forum-id}, '', @url-for-page(n)

  # Reconfigure an existing pager with new options.  This is usually used when page mutations happen.
  # @param Object pager
  # @param Object options
  init: ->
    @height = @$el.height! # ph -> pager height
    @indicator-height = indicator-height(@last, @height)
    #@indicator-positions = scan (+ @indicator-height), 0, [1 to @last-1]

  #
  on-click-set-page: (ev) ~>
    page = page-from-click-height(ev.offsetY, @indicator-height)
    @set-page page

  #
  on-resize-re-init: (ev) ~>
    @init!

