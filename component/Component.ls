if window?
  dollarish = window.$
else
  require! dollarish:cheerio

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
    @@$ = dollarish # shortcut
    component-name: \Component
    # locals is the locals used to instantiate the Component
    # locals is passed thru a template then mutate phase
    #
    # @$ represents a full featured jqueryish which is selected on the
    # component instances' container
    #
    # @$ could be thought of as 'the container'
    ({@locals = {}, attach = @is-client, render = true} = {}, @$) ~>
      @$ ||= @@$ '<div/>'

      @$.add-class @component-name # add class-name to container

      @render! if render

      # attach last just in case attach phase needs dom of component available
      @attach(false) if attach

      @children = @children! if @children # instantiate children
    is-client: !!window?
    template: (-> '')
    attach: (do-children = true) ->
      unless @is-client then throw new Error "Component can only attach on client"

      return @ if @is-attached # guard from attaching twice

      if @children and do-children
        for child in @children
          child.attach!

      @on-attach! if @on-attach
      @is-attached = true
      return @ # chain chain chain! chain of fools...
    detach: ->
      unless @is-client then throw new Error "Component can only detach on client"

      return @ unless @is-attached # guard from detaching twice

      if @children
        for child in @children
          child.detach!

      @on-detach! if @on-detach
      @is-attached = false
      return @ # chain chain chain! chain of fools...
    # programmer/sub-classer can override render
    # it just needs to output html given @locals
    render: ->
      # Render js template
      #   could be any function that takes locals as the first argument
      #   and returns an html markup string. I use compiled Jade =D
      template-out = @template @locals

      # skip dom phase unless there is a mutate action defined or children defined
      html-out =
        if @mutate or @children
          # Wrap output in top-level div before creating DOM
          # - allows us to find the topmost node in our template
          # - makes $c.html! return the correct html, including all markup
          $dom = @@$('<div class="render-wrapper">' + template-out + '</div>')

          # Mutation phase (in DOM)
          #   DOM manipulation can be done here
          @mutate $dom if @mutate

          # render children in their respective containers
          if @children
            for child in @children
              if child.$.selector
                $child-top = $dom.find(child.$.selector)
                $child-top.html child.render!
              else
                throw new Error "child Components must specify a container"

          # finally store html markup
          # pre-calculate and store s
          $dom.html!
        else
          template-out

      @$.html html-out # place into container
      return @
    html: -> @$.html!
