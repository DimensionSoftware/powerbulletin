require! {
  Component: yacomponent
  ch: \../app/client-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    const prefix = \list_
    const opts =
      handle: \div
      items:  \li
      max-levels: 2
      tolerance: \pointer
      tolerance-element: '> div'
      placeholder: \placeholder

    template: templates.AdminMenu
    current:  null # active "selected" menu item

    show:         ~> set-timeout (~> @$.find \.col2 .show 300ms), 300ms
    clone: (item) ~> # clone a templated defined as class="default"
      e = @$.find \.default .clone!remove-class(\default).attr \id, item.id
      e.find \input # add metadata to input
        ..data \form,  item.data?form
        ..data \title, item.data?title
        ..val item.data?title
      e
    current-store: !~>
      unless e = @current then return # guard
      form = @$.find \form
      if form
        # form values -> json data
        data = {}
        form.find \input |> each (input) ->
          $i = @$ input
          n = $i?attr \name
          v = $i?val!
          if n and n isnt \menu
            data[n] = switch $i.attr \type
              | \radio # must always have a value
                if $i.is \:checked
                  $i.val! # value if checked
                else
                  data[n] # keep last value
              | \checkbox
                !!$i.is \:checked
              | \text \hidden # always value
                v

        e # store
          ..data \form, data
          ..data \title, @current.val!
        console.log \store-title:, e.data \title
    current-restore: !~>
      unless e = @current then return # guard
      # set visually active
      $ \.col1 .find \.active .remove-class \active
      e.add-class \active

      # restore title + form
      if html-form = @$.find \form
        {form, title} = @current.data!
        e.val title
        console.log \data-to-restore:, title, form
        html-form # reset & default form
          ..get 0 .reset!
          ..find 'input[type="radio"]' .prop \checked, null
        if form # restore current's menu + title
          @current.val title
          @$.find 'form input' |> each (input) ->
            $i = @$ input
            n = $i?attr \name
            v = $i?val!
            if n and n isnt \menu
              switch $i.attr \type
                | \radio
                  if form[n] is v then $i.prop \checked, \checked
                | \checkbox
                  $i.attr \checked (if form[n] then \checked else false)
                | \text \hidden # always value
                  $i.val form[n]

    on-attach: !~>
      #{{{ Event Delegates
      @$.on \click \.onclick-add (ev) ~>
        @show!

        s = @$.find \.sortable
        # generate id & add new menu item!
        max = parse-int maximum(s.find \li |> map (-> it.id.replace prefix, ''))
        id  = unless max then 1 else max+1
        e   = @clone {id:"#prefix#id"}
        @$.find \.sortable
          ..append e
          ..nested-sortable opts
          ..find \input # select & focus
            ..focus!
        false

      # save menu
      @$.on \click 'button[type="submit"]' (ev) ~>
        @current-store!

        # get entire menu
        menu = @$.find \.sortable .data(\mjsNestedSortable).to-hierarchy! # extended to pull data attributes, too
        #unless menu.length then menu = [menu] # box
        console.log \saving-nested-sortable:, menu
        form = @$.find \form
        form.append(@@$ \<input> # append new menu
          .attr \type, \hidden
          .attr \name, \menu
          .val JSON.stringify menu)
        submit-form ev, (data) ->
          f = $ this # form
          t = $(form.find \.tooltip)
          show-tooltip t, unless data.success then (data?errors?join \<br>) else \Saved!

      @$.on \change \form (ev) ~> @current-store!  # save active title & form
      @$.on \focus  \.row (ev) ~> # load data for active row
        @current = $ ev.target
        @current-restore!
      #}}}
      # pre-load nested sortable list + initial active
      # - safely assume 2 levels max for now)
      s    = @$.find \.sortable
      site = @state.site!
      menu = site.config.menu

      if menu # init ui
        data = JSON.parse if typeof menu is \object then menu.0 else menu
        for item in data
          if item.id
            item.id = "#prefix#{item.id}"
            s.append(@clone item)

      @show! # bring in ui
      set-timeout (-> # activate first
        unless s.find \input:first .length then @$ \.onclick-add .click! # add unless exists
        s.find \input:first .focus!), 200ms
      s.nested-sortable opts # init

    on-detach: -> @$.off!

# vim:fdm=marker
