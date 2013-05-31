require! {
  $R: reactivejs
}

if window?
  $ = window.$
else
  require! $:cheerio

!function bench subject-name, subject-body
  bef = new Date
  subject-body!
  aft = new Date
  set-timeout(_, 1) ->
    dur = aft - bef
    console.log "benchmarked '#{subject-name}': took #{dur}ms"

# like inner html, except super rice
# mutant has lots of entropy so we can avoid the teardown performance hit
# http://blog.stevenlevithan.com/archives/faster-than-innerhtml
!function replace-html $el, html
  if window?
    el = $el.0
    new-el = el.clone-node false
    new-el.inner-HTML = html
    el.parent-node.replace-child new-el, el
  else
    # server side cheerio does the normal thing
    $el.html html


module.exports =
  class Component
    (@locals = {}, top) ~>
      if top
        @$top = $ top

        # unique class
        unique-class =
          'c-' + (Math.random! * (new Date)).to-string!replace '.' ''
        console.log {unique-class}

        @$top.add-class unique-class
        @selector = '.' + unique-class

      # auto-attach on client
      @attach! if window?

    template: (-> '')
    mutate: !-> # override in sub-class as needed
    children: [] # override in sub-class as needed
    attach: !-> # override in sub-class as needed (client only)
    detach: !-> # override in sub-class as needed (client only)
    # programmer/sub-classer can override html
    # it just needs to maintain and consume @locals to produce a return
    # result of html
    html: ->
      # Render js template
      #   could be any function that takes locals as the first argument
      #   and returns an html markup string. I use compiled Jade =D
      template-out = @template @locals

      # Wrap output in top-level div before creating DOM
      # - allows us to find the topmost node in our template
      # - makes $c.html! return the correct html, including all markup
      $dom = $('<div class="render-wrapper">' + template-out + '</div>')

      # Mutation phase (in DOM)
      #   DOM manipulation can be done here
      @mutate $dom

      for child in @children
        console.log 'child.$top.selector'
        if child.$top
          $dom.find(child.selector).html child.render!
        else
          throw new Error "child Components must specify a top"

      # finally store html markup
      # pre-calculate and store s
      $dom.html!
    render: ->
      @cached-html = @html!
    # use cached result or render 
    put: !-> # put in html in $(@selector), use cached-copy or render if necessary
      if @$top
        @$top.html(@cached-html or @render!)
      else
        throw new Error "Component cannot put since a top was not passed in"
