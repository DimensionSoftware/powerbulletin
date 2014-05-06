define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Uploader
}
{lazy-load-nested-sortable, show-info, show-tooltip, submit-form, storage} = require \../client/client-helpers if window?
{each, map, maximum} = require \prelude-ls

module.exports =
  class AdminMenu extends PBComponent
    const prefix = \list_
    const opts   =
      handle: \div
      items:  \li
      max-levels: 3
      tolerance: \pointer
      tolerance-element: '> div'
      placeholder: \placeholder
      is-tree: true
      start-collapsed: true
      tab-size: 25
      revert: 100
      expand-on-hover: 800ms
      opacity: 0.8
      force-placeholder-size: true
      is-allowed: (item, parent) ->
        # only move items with a type
        unless (item.find \.row .data \form)?dialog
          show-tooltip ($ \#warning), 'Select a Type First!'
          item.find \input .add-class \has-error
          return false
        true

    current:  null # active "selected" menu item

    show: ->
      set-timeout (~> @$.find \.col2 .show 300ms), 300ms

    clone: (item) -> # clone a template defined as class="default"
      e = @$.find \.default .clone!remove-class(\default).attr \id, item.id
      e.find \input # add metadata to input
        ..data \id,    item.id.replace /list_/ ''
        ..data \form,  item.data?form
        ..data \title, item.data?title
        ..val item.data?title
      e.find \.icon .add-class "s-#{item.form?dialog}-icon"
      e
    current-store: !->
      unless e = @current then return # guard
      html-form = @$.find \form.menus
      if html-form
        # form values -> json data
        data = {}
        html-form.find 'input,textarea' |> each (input) ->
          $i = @$ input
          n = $i?attr \name
          v = $i?val!
          if n and n isnt \menu
            data[n] = switch $i.attr \type
              | \radio # must always have a value
                if $i.is \:checked then v else data[n] # current or use last
              | \checkbox
                !!$i.is \:checked
              | \text \hidden # always value
                v
              | otherwise
                if $i.is \textarea
                  v
        data.background = (html-form.find \.background).data \src
        e # store
          ..remove-class \has-error
          ..data \id,    e.data!id.replace /list_/ ''
          ..data \form,  data
          ..data \title, e.val!
    current-restore: !->
      unless e = @current then return # guard

      # set visually active
      $ \.col1 .find \.active .remove-class \active
      e.add-class \active
      e.parents \li:first .add-class \active

      # restore title + form
      if html-form = @$.find \form.menus
        {id, form, title} = @current.data!
        e.val title
        html-form # default form
          ..find \fieldset .toggle-class \has-dialog (!!form?dialog)
          ..find '#placeholder_title, #link_title, #page_title, #forum_title, #forum_slug, #page_slug, #url, textarea' .val ''
          ..find 'input[type="checkbox"], input[type="radio"]' .prop \checked, false
        if form # restore current's id + menu + title
          e.val title
          form{id, title} = {id, title}
          # init-html5-uploader
#          @uploader.detach! if @uploader # cleanup
#          @uploader = new Uploader {
#            locals:
#              name: 'Header Image'
#              preview: form.header
#              post-url: "/resources/forums/#{form.dbid}/header"
#              on-delete: ~>
#                @current-store!
#              on-success: (xhr, file, r-json) ~>
#                @current-store!}, \#uploader_component
#          @uploader = new Uploader {
#            locals:
#              preview: form.background
#              post-url: "/resources/forums/#{form.dbid}/background"
#              on-delete: ~>
#                # remove background from config
#                @$.find 'form.menus .background' .data \src, ''
#                @current-store!
#              on-success: (xhr, file, r-json) ~>
#                @current-store!}, \#uploader_component
          # set input values
          html-form.find 'input,textarea' |> each (input) ->
            $i = @$ input
            n = $i?attr \name
            v = $i?val!
            if n and n isnt \menu and n isnt \action
              switch $i.attr \type
                | \radio
                  if form[n] is v then $i.prop \checked, \checked
                | \checkbox
                  $i.prop \checked (if form[n] then \checked else false)
                | \text \hidden # always value
                  if n.match /Title$/ then form[n] = title # set title for page, forum, placeholder, link, etc...
                  $i.val form[n]
                | otherwise
                  if $i.is \textarea
                    $i.val form[n]

    store-title: (ev) !~>
      $input     = $ ev.target
      data       = $input.data!
      data.title = data.form.title = $input.val!
      @$.find 'input[name=title]' .val $input.val!
      $input.data data
      $ '.dialog:visible input:first' .val data.title # sync dialog's title

    to-hierarchy: ->
      @$.find \.sortable .data(\mjsNestedSortable).to-hierarchy!

    resort: (ev, ui) !~>
      # guard unless item has a type to avoid nulls
      return unless (ui.item.find \.row .data \form)?dialog
      id    = ui.item.attr \id .replace /^list_/ ''
      $form = @$.find \form
      url   = $form.attr \action
      req =
        method : \PUT
        url    : url
        data:
          action : \menu-resort
          id     : id
          tree   : JSON.stringify @to-hierarchy!
      jqxhr = @@$.ajax req

    delete: (row) !->
      if confirm "Permanently Delete #{row.val!}?"
        req =
          method : \PUT
          url    : @$.find \form.menus .attr \action
          data:
            action : \menu-delete
            id     : row.parents \li .attr \id .replace /^list_/ ''
        @@$.ajax req
          .done (data) ~>
            nearest  = row.parents \li:first
            adjacent = nearest.prev \li:first
            unless data?errors
              # if success, remove & focus above
              nearest.remove!
              adjacent.find \.row .focus!
            unless data.success # handle error
              show-tooltip ($ \#warning), data?errors?join \<br>
              nearest.focus!
          .fail (jqxhr, status, err) ~>
            console?warn status, err

    build-nested-sortable: ($ol, menu) ->
      for item in menu
        if item
          # add item to $ol
          if id = item.id
            form = item.form
            item.data ||= {}
              ..form  = form
              ..title = form?title
            item.id = "#prefix#id"
            $item = @clone item
            $ol.append($item)
          # if item has children, create a sub $ol and recurse
          if item.children?length
            $item?add-class \mjs-nestedSortable-collapsed # default collapsed
            $sub-ol = $('<ol/>')
            $item?append $sub-ol
            @build-nested-sortable $sub-ol, item.children

    on-attach: !->
      #{{{ Event Delegates
      @$.on \keydown, '#forum_title, #page_title, #link_title, #placeholder_title' (ev) ~>
        title = $ ev.target .val! # title
        # sync with data to be saved
        [prefix, suffix] = ev.target.id.split \_
        title-field = prefix + suffix.0.to-upper-case! + (suffix.substr 1)
        d = @current.data!
        d.title = d.form.title = d.form[title-field] = title
        @$.find 'input[name=title]' .val title
        @current
          ..val  title
          ..data d
      @$.on \click \.option (ev) -> # correct sprite when adding new menu item
        $ \.s-undefined-icon
          ..remove-class \s-undefined-icon
          ..add-class "s-#{$ ev.target .attr \id}-icon"
      @$.on \click \.icon (ev) -> ($ ev.target .next \input).focus!
      @$.on \click \.disclose (ev) ~>
        $ ev.target .closest \li
          ..toggle-class \mjs-nestedSortable-collapsed
          ..toggle-class \mjs-nestedSortable-expanded
        @store-sortable-tree!

      @$.on \change 'input[name="dialog"]' ~> # type was selected
        # TODO - make sure current-restore has the right data to restore; when adding a new item, it often does not.
        $ \#warning .remove-class \hover # hide tooltip
        # TODO - create slug out of title
        @$.find \fieldset .add-class \has-dialog .find \input:visible:first .focus!

      @$.on \keyup, 'input.active', @store-title
      @$.on \keypress, 'form input', -> # disable form submit on enter press
        if (it.key-code or it.which) is 13
          it.prevent-default!
          false

      @$.on \click \.onclick-close (ev) ~>
        @delete ($ ev.target .prev \.row) # extract row

      @$.on \click \.onclick-add (ev) ~>
        @show!
        show-tooltip ($ \#warning), 'Choose a Type for This Menu Item!', 20000ms # closes early when selected

        s = @$.find \.sortable
        # generate id & add new menu item!
        max = maximum(s.find \li |> map (-> parse-int it.id.replace(prefix, '')))
        id  = unless max then 1 else max+1
        e   = @clone {id:"#prefix#id"}

        default-data =
          id    : id.to-string!
          title : ""
          form  :
            action       : \menu
            content      : ""
            content-only : false
            dbid         : ""
            dialog       : ""
            forum-slug   : ""
            id           : id.to-string!
            locked       : false
            page-slug    : ""
            seperate-tab : false
            title        : ""
            url          : ""

        @$.find \.sortable
          ..append e
          ..nested-sortable { stop: @resort } <<< opts
          ..find \.disclose .on \click, ~> # bind expand/collapse behavior
            @store-sortable-tree!
            $ @ .closest \li
              ..toggle-class \mjs-nestedSortable-collapsed
              ..toggle-class \mjs-nestedSortable-expanded

        e.find \input .data default-data
        e.find \input:first .focus!0.scroll-into-view!
        false

      # save menu
      @$.on \click 'button[type="submit"]' (ev) ~>
        @current-store!

        # get entire menu
        menu = @to-hierarchy! # extended to pull data attributes, too
        form = @$.find \form
        form.find '[name="active"], [name="menu"]' .remove! # prune old
        form.append(@@$ \<input> # append new menu
          .attr \type, \hidden
          .attr \name, \menu
          .val JSON.stringify menu)
        submit-form ev, (data) ~> # save to server
          data-form = @current.data \form # FIXME - Even though I try to set a new dbid, it gets blasted away somewhere.
          data-form.dbid = data.id
          @$.find 'input[name=dbid]' .val data.id
          @current.data \form, data-form
          f = $ this # form
          show-tooltip $(\#warning), unless data.success then (data?errors?join \<br>) else \Saved!

      @$.on \change \form (ev) ~> @current-store! # save active title & form
      @$.on \focus  \.row (ev) ~> @current = $ ev.target; @current-restore! # load active row
      @$.on \blur   \.row (ev) ~> show-tooltip ($ \#warning) # hide
      #}}}

      ####  main  ;,.. ___  _
      <~ lazy-load-nested-sortable
      # pre-load nested sortable list + initial active
      # - safely assume 2 levels max for now)
      s    = @$.find \.sortable
      site = @state.site!
      menu = site.config.menu

      if menu # init ui
        menu = JSON.parse menu if typeof menu is \string
        @build-nested-sortable s, menu

      @show! # bring in ui
      set-timeout (~> # activate first
        @restore-sortable-tree!
        unless s.find \input:first .length then @$ \.onclick-add .click! # add unless exists
        # show intro to user?
        const seen-intro = "#{window.user?id}-admin-intro"
        unless storage.get seen-intro
          storage.set seen-intro, true
          show-info 0,
            [\.col1,              '<b>Welcome!</b> Each Item Added Becomes Part of Your Main Menu', true],
            [\.col1,              'Click &amp; Drag Menu Items to <b>Rearrange</b>', true],
            ['.col2 .has-dialog', 'Fill in the remaining information and Click <b>Save</b>']
        s.find \input:first .focus!), 10ms
      s.nested-sortable { stop: @resort } <<< opts # init

    on-detach: -> @$.off!

    const skey = \admin-sortable
    store-sortable-tree: -> # store tree state: [id, classes]
      storage.set skey, (@$.find '.sortable li' |> map -> [it.id, it.class-name])
    restore-sortable-tree: -> # restore tree state
      if state = storage.get skey
        state |> each ->
          [id, classes] = it
          @@$ "\##id" .attr \class, classes

# vim:fdm=marker
