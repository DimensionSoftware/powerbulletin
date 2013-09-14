define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
ch = require \../client/client-helpers if window?

{templates} = require \../build/component-jade
{each, map, maximum} = require \prelude-ls

module.exports =
  class AdminMenu extends Component
    const prefix = \list_
    const opts =
      handle: \div
      items:  \li
      max-levels: 3
      tolerance: \pointer
      tolerance-element: '> div'
      placeholder: \placeholder

    template: templates.AdminMenu
    current:  null # active "selected" menu item

    show:         ~> set-timeout (~> @$.find \.col2 .show 300ms), 300ms
    clone: (item) ~> # clone a template defined as class="default"
      e = @$.find \.default .clone!remove-class(\default).attr \id, item.id
      e.find \input # add metadata to input
        ..data \id,    item.id.replace /list_/ ''
        ..data \form,  item.data?form
        ..data \title, item.data?title
        ..val item.data?title
      e
    current-store: !~>
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
        e # store
          ..data \id,    e.data!id.replace /list_/ ''
          ..data \form,  data
          ..data \title, e.val!
    current-restore: !~>
      unless e = @current then return # guard
      # set visually active
      $ \.col1 .find \.active .remove-class \active
      e.add-class \active

      # restore title + form
      if html-form = @$.find \form.menus
        {id, form, title} = @current.data!
        e.val title
        html-form # default form
          ..find \fieldset .toggle-class \has-dialog (!!form?dialog)
          ..find '#forum_slug, #page_slug, #url, textarea' .val ''
          ..find 'input[type="checkbox"], input[type="radio"]' .prop \checked, false
        if form # restore current's id + menu + title
          e.val title
          form{id, title} = {id, title}
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

    to-hierarchy: ~>
      @$.find \.sortable .data(\mjsNestedSortable).to-hierarchy!

    resort: (ev, ui) !~>
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

    delete: (row) !~>
      if confirm "Permanently Delete #{row.val!}?"
        req =
          method : \PUT
          url    : @$.find \form.menus .attr \action
          data:
            action : \menu-delete
            id     : row.parents \li .attr \id .replace /^list_/ ''
        @@$.ajax req
          .done (data) ~>
            $container = row.parents('li')
            $cursor = @$.find 'ol.sortable li:first'
            $container.remove!
            $cursor.focus!
          .fail (jqxhr, status, err) ~>
            console.warn status, err

    build-nested-sortable: ($ol, menu) ~>
      for item in menu
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
          $sub-ol = $('<ol/>')
          $item.append $sub-ol
          @build-nested-sortable $sub-ol, item.children

    on-attach: !~>
      #{{{ Event Delegates
      @$.on \change 'input[name="dialog"]' ~> # type was selected
        # TODO - make sure current-restore has the right data to restore; when adding a new item, it often does not.
        # TODO - create slug out of title
        @$.find \fieldset .add-class \has-dialog .find \input:visible .focus!

      @$.on \keyup, 'input.active', @store-title

      @$.on \click \.onclick-close (ev) ~>
        @delete ($ ev.target .prev \.row) # extract row

      @$.on \click \.onclick-add (ev) ~>
        @show!

        s = @$.find \.sortable
        # generate id & add new menu item!
        max = parse-int maximum(s.find \li |> map (-> it.id.replace prefix, ''))
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
          ..nested-sortable opts

        e.find \input .data default-data
        e.find \input .focus!
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
        ch.submit-form ev, (data) ~>
          data-form = @current.data \form   # FIXME - Even though I try to set a new dbid, it gets blasted away somewhere.
          data-form.dbid = data.id
          @$.find 'input[name=dbid]' .val data.id
          @current.data \form, data-form
          f = $ this # form
          t = $(form.find \.tooltip)
          ch.show-tooltip t, unless data.success then (data?errors?join \<br>) else \Saved!

      @$.on \change \form (ev) ~> @current-store! # save active title & form
      @$.on \focus  \.row (ev) ~> @current = $ ev.target; @current-restore! # load active row
      #}}}

      ####  main  ;,.. ___  _
      # pre-load nested sortable list + initial active
      # - safely assume 2 levels max for now)
      s    = @$.find \.sortable
      site = @state.site!
      menu = site.config.menu

      if menu # init ui
        menu = JSON.parse menu if typeof menu is \string
        @build-nested-sortable s, menu

      @show! # bring in ui
      set-timeout (-> # activate first
        unless s.find \input:first .length then @$ \.onclick-add .click! # add unless exists
        s.find \input:first .focus!), 200ms
      s.nested-sortable { stop: @resort } <<< opts # init

    on-detach: -> @$.off!

# vim:fdm=marker
