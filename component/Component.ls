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
    (state, @selector) ->
      @merge-state state

      # bind passed in state to render by default
      # this gives us 'reactive programming for free with jade'
      # but its not optimal necessarily...
      #
      # in the future look into an option to bypass this for manual dom manip
      # i.e. can be overridden by the programmer
      r-put = $R ~>
        bench "#{@@display-name} (RENDER)" ~> @render!

        put = ~>
          bench "#{@@display-name} (PUT)" ~> @put!

        if raf = window?request-animation-frame
          raf put
        else
          put!

      for ,r-var of @r
        r-put.bind-to r-var

      @$top = $ @selector

      # auto-attach on client only and only when @$top is defined
      if window? and @$top
        # attach delegated event handlers
        # we do not put the output in @$top yet because
        # we want to yield this functionality to something smarter
        # which can use request-animation frame
        @attach!

    template: (-> '')
    mutate: !-> # override in sub-class as needed
    children: [] # override in sub-class as needed
    attach: !-> # override in sub-class as needed (client only)
    detach: !-> # override in sub-class as needed (client only)
    merge-state: !(state) ->
      @r ||= {}
      for k,v of state
        if existing-r = @r[k]
          existing-r v # set rather than override hash key
        else
          @r[k] = $R.state v
    state: -> {[k, v.get!] for k,v of @r}
    render: ->
      state = @state!
      # Render js template
      #   could be anything that takes locals as the first argument
      #   and returns html markup. I use compiled Jade =D
      template-out = @template state

      # Wrap output in top-level div before creating DOM
      # - allows us to find the topmost node in our template
      # - makes $c.html! return the correct html, including all markup
      $c = $('<div class="render-wrapper">' + template-out + '</div>')

      # Mutation phase (in DOM)
      #   DOM manipulation can be done here
      @mutate $c, state

      for child in @children
        $c.find(child.selector).html child.render!

      # finally store html markup
      # pre-calculate and store s
      @html = $c.html!
    put: !-> # put in @$top (client only)
      replace-html(@$top, @html or @render!)

