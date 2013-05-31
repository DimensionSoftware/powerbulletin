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
      if typeof top is \string # css selector
        @selector = top # usually from a child declaration
        @$top = $ @selector #
      else if typeof top is \object # jqueryish
        @selector = top.selector
        @$top = top # jqueryish

      # add unique selector class to top only on client, allows for attaching
      # delegated events to document without breaking instance abstraction
      #
      # only on client...
      # this way we keep it out of static html compositing (the ugly classes)
      # since server doesn't ever need to attach...
      if window?
        unique-class =
          'c-' + (Math.random! * (new Date)).to-string!replace '.' ''

        # for ease of detaching / removing delegated events at the document level
        @$top.add-class unique-class

        @unique-selector = '.' + unique-class

      # auto-attach on client
      @attach! if window?

    template: (-> '')
    attach: !->
      unless window? then throw new Error "Component can only attach on client"
      unless @$top then throw new Error "Component can't attach without a specified top"

      if @children
        for child in @children
          child.attach!

      @on-attach! if @on-attach
    detach: !->
      unless window? then throw new Error "Component can only detach on client"
      unless @$top then throw new Error "Component can't attach without a specified top"

      if @children
        for child in @children
          child.detach!

      @on-detach! if @on-detach
    # programmer/sub-classer can override html
    # it just needs to maintain and consume @locals to produce a return
    # result of html
    html: ->
      # Render js template
      #   could be any function that takes locals as the first argument
      #   and returns an html markup string. I use compiled Jade =D
      template-out = @template @locals

      # skip dom phase unless there is a mutate action defined or children defined
      if @mutate or @children
        # Wrap output in top-level div before creating DOM
        # - allows us to find the topmost node in our template
        # - makes $c.html! return the correct html, including all markup
        $dom = $('<div class="render-wrapper">' + template-out + '</div>')

        # Mutation phase (in DOM)
        #   DOM manipulation can be done here
        @mutate $dom if @mutate

        # render children in their respective containers
        if @children
          for child in @children
            if child.selector
              $dom.find(child.selector).html child.render!
            else
              throw new Error "child Components must specify a selector top (string)"

        # finally store html markup
        # pre-calculate and store s
        $dom.html!
      else
        template-out
    render: ->
      @cached-html = @html!
    # use cached result or render 
    put: !-> # put in html in $(@selector), use cached-copy or render if necessary
      if @$top
        @$top.html(@cached-html or @render!)
      else
        throw new Error "Component cannot put since a top was not passed in"
