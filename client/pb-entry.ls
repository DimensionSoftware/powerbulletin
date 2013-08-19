define = window?define or require(\amdefine) module

require.config {
  paths:
    lodash: \//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.3.1/lodash.min
    jquery: \//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min
  shim:
    lodash: {exports: \_}
    jquery: {exports: \jQuery}
  map:
    '*': {cheerio: \jquery}
  packages:
    * name: \yacomponent
      location: \../packages/yacomponent
    * name: \mutant
      location: \../packages/mutant
}

define (require) ->
  require \jquery     # do this in the beginning, until all scripts are converted to lazy-style
  window.__ = require \lodash # same... not sure where we use window.__ but whatever, legacy...

  window.Chat  = require \../component/Chat
  window.Auth  = require \../component/Auth
  window.Pager = require \./pager
  window.furl  = require \./forum-urls
  window.tasks = require \./tasks
  window.ioc   = require \./io-client

  window.PhotoCropper = require \../component/PhotoCropper

  global <<< require(\prelude-ls/prelude-browser-min) \prelude-ls
  global <<< require \./shared-helpers
  global <<< require \./client-helpers

  # components
  require! \../component/Buy
  require! \../component/Paginator

  # XXX client-side entry
  # shortcuts
  $w = $ window
  $d = $ document

  left-offset = 50px

  #{{{ UI Interactions
  # ui save state
  sep = \-
  window.save-ui = -> # serialize ui state to cookie
    min-width = 200px
    w = $ \#left_content .width!
    s = $.cookie \s
    if s then [_, _, prev] = s.split sep
    w = if w > min-width then w else prev or min-width # default
    vals =
      if $ \body .has-class(\collapsed) then 1 else 0
      w
    $.cookie \s, vals.join(sep),
      path:   \/
      secure: true
  window.load-ui = -> # restore ui state from cookie
    s  = $.cookie \s
    $l = $ \#left_content

    if s # restore
      [collapsed, w] = s.split sep
      if collapsed is \1 and not $ \html .has-class \admin
        $ \body .add-class \collapsed # only collapse on non-admin mutants
        $l.find \.scrollable .get-nice-scroll!resize!
      w = parse-int w
      $l.transition({width: w} 500ms \easeOutExpo -> set-wide!)
      set-timeout (-> # ... & snap
        $ '#main_content .resizable' .transition({padding-left: w+left-offset} 450ms \snap)), 300ms
    set-timeout (-> set-wide!; align-breadcrumb!), 500ms

  # waypoints
  $w.resize (__.debounce (-> $.waypoints \refresh; respond-resize!; align-breadcrumb!), 800ms)

  # show reply ui
  append-reply-ui = (ev) ->
    # find post div
    $p = $ ev.target .parents \.post:first

    # append dom for reply ui
    unless $p.find('.reply .post-edit:visible').length
      render-and-append window,  $p.find(\.reply:first), \post-edit, (post:
        method:     \post
        forum_id:   $p.data(\forum-id) or window.active-forum-id
        parent_id:  $p.data \post-id
        is_comment: true), ->
          #if ev.original-event then $p.find('textarea[name="body"]').focus! # user clicked
          $p.find('textarea[name="body"]').focus!
    else
      $p.find('.reply .cancel').click!

  censor = (ev) ->
    $p = $ ev.target .parents \.post:first # find post div
    post-id = $p.data \post-id
    $.post "/resources/posts/#post-id/censor", (r) ->
      if r?success then $p.add-class \censored
  #}}}

  #.
  #### main   ###############>======-- -   -
  ##
  load-ui!
  set-timeout (-> $ \footer .add-class \active), 2500ms
  $ \#query .focus!select!

  # Delegated Events
  #{{{ - search and ui delegated events
  # window.ui is the object which will receive events and have events triggered on it
  window.$ui = $ {}

  window.r-searchopts = $R.state window.searchopts
  window.r-socket = $R.state! # do this early

  do ->
    # keys that aren't allowed to trigger the search
    # use hashmap so its O(1)
    const blacklist = {
      9:1   # tab
      17:1  # ctrl
      18:1  # alt
      27:1  # escape
      32:1  # space
      37:1  # arrow (left)
      38:1  # arrow (up)
      39:1  # arrow (right)
      40:1  # arrow (down)
      224:1 # mac command key
    }

    $d.on \keyup, \#query, __.debounce (->
      q = $(@).val!

      # ignore special keys
      unless blacklist[it.which]
        if it.which is 13 # enter key
          submit-type = \hard
        else
          submit-type = \soft

        #console.log "keyup:#{it.which} triggered a #{submit-type} search"
        newopts = {} <<< window.searchopts <<< {q, submit-type}
        delete newopts.page # remove page from new term searches
        r-searchopts newopts
    ), 500ms

  $d.on \change, '#search_filters [name=forum_id]', ->
    submit-type = \soft
    forum_id = $(@).val!

    newopts = {} <<< window.searchopts <<< {forum_id, submit-type}
    delete newopts.page # remove page from new filtered results
    r-searchopts newopts

    return false

  $d.on \change, '#search_filters [name=within]', ->
    console.log it
    submit-type = \soft
    within = $(@).val!

    newopts = {} <<< window.searchopts <<< {within, submit-type}
    delete newopts.page # remove page from new filtered results
    r-searchopts newopts

    return false

  $R((sopts) ->
    #should-search = sopts.submit-type is \hard or window.hints.current?mutator is \search
    #
    # WARNING!!!
    # XXX: this is a HACK
    # WARNING!!!
    #
    # I am doing this because in my testing I cannot rely on current mutator always being set properly when your on the search mutant!
    # I really DON'T want to but I am working around this weird shit so my filters will stop becoming unresponsive
    # we need to fix window.hints.current
    #
    parser = document.create-element \a
    parser.href = History.get-state!url
    uri = parser.pathname

    should-search = sopts.submit-type is \hard or uri is '/search'

    should-replace = sopts.submit-type is \soft

    # cleanup so it doesn't end up in url, only used to figure out push vs replace
    delete sopts.submit-type

    # strip out '', null, undefined, and 0 from querystring to keep it prety
    [k for k,v of sopts when not v].map -> delete sopts[it]

    if should-search
      #console.log 'search request:', sopts
      qs = $.param sopts
      uri = "/search#{if qs then \? else ''}#{qs}"

      window.last-statechange-was-user = false # flag that this was programmer, not user
      if should-replace
        History.replace-state {}, '', uri
      else
        History.push-state {}, '', uri

  ).bind-to(r-searchopts)

  $ui.on \thread-create, (e, thread) ->
    console.info 'thread-create', thread
    <- render-and-prepend window,  $('#left_container .threads'), \thread, thread:thread
    $ '#left_container .threads div.fadein li' .unwrap!

  $ui.on \nav-top-posts, (e, threads) ->
    console.info \stub, threads

  #}}}
  # {{{ - generic form-handling ui
  $d.on \click '.create .no-surf' Auth.require-login((ev) ->
    $ '#main_content .forum' .html '' # clear canvas
    e = $ ev.target
    edit-post e.data(\edit), forum_id:window.active-forum-id)
  $d.on \click \.edit.no-surf Auth.require-login((ev) ->
    edit-post $(ev.target).data \edit)
  $d.on \click '.onclick-submit .cancel' (ev) ->
    f = $(ev.target).closest(\.post-edit)  # form
    f.hide 350ms \easeOutExpo
    meta = furl.parse window.location.pathname
    switch meta.type
    | \new-thread => History.back!
    | otherwise   => remove-editing-url meta
    false

  submit = Auth.require-login(
    (ev) -> submit-form(ev, (data) ->
      f = $(ev.target).closest(\.post-edit) # form
      p = f.closest \.editing # post being edited
      t = $(f.find \.tooltip)
      unless data.success
        show-tooltip t, data?errors?join \<br>
      else
        # render updated post
        p.find \.title .html data.0?title
        p.find \.body  .html data.0?body
        f.remove-class \fadein .hide 200ms # & hide
        meta = furl.parse window.location.pathname
        window.last-statechange-was-user = false # flag that this was programmer, not user
        switch meta.type
        | \new-thread => History.replace-state {} '' data.uri
        | \edit       => remove-editing-url meta
      false))

  # editing & posting
  # - ckeditor
  ck-submit = Auth.require-login((ev) ->
    ck-submit-form({element:{$:{id:\editor}}}, (data) -> post-success ev, data); false)
  # - standard form
  post-submit = Auth.require-login((ev) -> submit-form(ev, (data) -> post-success ev, data); false)

  submit-selectors =
    * "html.profile .onclick-submit button[type='submit']"
    * "html.forum .onclick-submit button[type='submit']"
    * "html.search .onclick-submit button[type='submit']"
  $d.on \click, submit-selectors.join(', '), post-submit
  $d.on \keydown \.onshiftenter-submit ~> if it.which is 13 and it.shift-key then post-submit it

  $d.on \click \.onclick-append-reply-ui Auth.require-login(append-reply-ui)
  $d.on \click \.onclick-censor-post Auth.require-login(censor)
  #}}}
  #{{{ - header (main menu)
  #$d.on \click 'html.homepage header .menu a.title' ->
  #  awesome-scroll-to $(this).data \scroll-to; false
  $d.on \click 'html header .menu a.title' mutate

  # search header
  $d.on \click 'header .onclick-close' (e) ->
    $ \#query .val('').focus!
    History.back!
  #{{{ - left_nav handle
  $d.on \click \#handle ->
    $l = $ \#left_content
    $ \body .toggle-class \collapsed
    $ '#main_content .resizable'
      .css(\padding-left, ($l.width! + left-offset))
    save-ui!
  #}}}

  # {{{ Mocha testing harness
  if mocha? and window.location.search.match /test=1/
    cleanup-output = ->
      $('body > *:not(#mocha)').remove!
      mocha-css-el = # mocha style (JUST IN TIME!)
        $("<link rel=\"stylesheet\" type=\"text/css\" href=\"#{window.cache-url}/local/mocha.css\">")
      $ \head .append(mocha-css-el)

    mocha.setup \bdd

    # actual tests
    $.get-script "#{window.cache-url}/tests/test1.js", ->
      run = ->
        mocha.run cleanup-output
      set-timeout run, 2000ms # gotta give time for tests to load
  #}}}
  #}}}
  #{{{ - chat
  $d.on \click  \.onclick-chat Auth.require-login( (ev) ->
    profile-name = $ 'div.profile:first' .data \user-name
    f  = user
    $p = $ \div.profile:first
    t  =
      id     : $p.data \user-id
      name   : $p.data \user-name
      photo  : $p.find \img .attr \src
    Chat.start [f, t]
  )
  #}}}
  #{{{ - admin
  $d.on \click 'html.admin .onclick-submit button[type="submit"]' (ev) ->
    submit-form(ev, (data) ->
      f = $ this # form
      t = $(f.find \.tooltip)
      inputs = # class to apply & which input
        saved: f.find 'input, textarea'

      f.find \input:first .focus!select! unless f.has-class \no-focus
      if data?success
        # indicated saved
        show-tooltip t, (t.data(\msg) or \Saved!)
        for k, v of inputs
          for e in v
            e = $ e
            e.add-class k
            if e.has-class \clear then e.val '' # clear value
        set-timeout (-> # reset ui
          for k, v of inputs
            for e in v
              $ e .remove-class k), 3000ms
      else # indicated failure
        show-tooltip t, data?msg
    )
  $d.on \change 'html.admin .domain' -> # set keys
    id = parse-int($ '.domain option:selected' .val!)
    domain = find (.id is id), site.domains
    for k in [
      \facebookClientId
      \facebookClientSecret
      \twitterConsumerKey
      \twitterConsumerSecret
      \googleConsumerKey
      \googleConsumerSecret]
        $ "[name='#k']" .val domain.config[k]
  subscribe = (what) -> unless what in site.subscriptions
    do-buy what
    false
  $d.on \click 'html.admin #private'   -> subscribe \private
  $d.on \click 'html.admin #analytics' -> subscribe \analytics
  #}}}
  # {{{ - components
  window.component = {}

  $d.on \click \.onclick-buy (ev) -> do-buy($ ev.target .data \product)
  window.do-buy = (product-id) ->
    throw new Error "window.do-buy must specify a product-id" unless product-id
    <- lazy-load-fancybox
    product <- $.get(\/resources/products/ + product-id)
    locals = {product, card-needed:!window.site?has_stripe}

    b = window.component?buy # existing?
    if b then b.detach!      # cleanup
    b = window.component.buy = new Buy {locals}
    $.fancybox b.$, fancybox-params
  #}}}

  # vim:fdm=marker
