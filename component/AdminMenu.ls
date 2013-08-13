require! {
  Component: yacomponent
  ch: \../app/client-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    const opts =
      handle: \div
      items:  \li
      max-levels: 2
      tolerance: \pointer
      tolerance-element: '> div'
      placeholder: \placeholder

    template: templates.AdminMenu
    current:  null # active "selected" menu item

    show:       ~> set-timeout (~> @$.find \.col2 .show 300ms), 300ms
    clone: (id) ~> # clone a templated defined as class="default"
      @$.find \.default .clone!remove-class(\default).attr \id, id
    current-store: !~>
      if @current # store
        f = @$.find \form
        f.find 'input[name="menu"]' .remove!  # prune old form data
        @$.data @current, \menu, f.serialize! # create & store new
        console.log \current:, @current
        console.log \stored:, f.serialize!
        console.log \val:, @current.val!
    current-restore: !~>
      m = @$.data @current, \menu
      f = @$.find \form
      if m?length # restore current's menu
        f.deserialize m
        console.log \restored:, m
      else
        console.log \defaulted
        f.get 0 .reset! # default

    init: !~>

    on-attach: !~>
      # pre-load nested sortable list + initial active
      # - safely assume 2 levels max for now)
      s = @$.find \.sortable
      site = @state.site!
      for item in JSON.parse site.config.menu # render parent menu
        s.append(@clone item.id) if item.id
        if item.menu # ... & siblings
          for sub-item in JSON.parse item?menu
            item.append(@clone sub-item.id)
      if site.config.menu # init ui
        s.nested-sortable opts
        set-timeout (-> s.find \input:first .focus!), 200ms
        @show!

      @$.on \click \.onclick-add (ev) ~>
        @show!

        const prefix = \list_
        # generate id & add new menu item!
        max = parse-int maximum(s.find \li |> map (-> it.id.replace prefix, ''))
        id  = unless max then 1 else max+1
        s
          ..append(@clone "#prefix#id")
          ..find \input .focus!
          ..nested-sortable opts
        @current-restore!
        false

      # save menu
      @$.on \click 'button[type="submit"]' (ev) ~>
        @current-store!

        # get entire menu
        menu = @$.find \.sortable .data(\mjsNestedSortable).to-hierarchy! # extended to pull data attributes, too
        f = @$.find \form
        f.append(@@$ \<input>                # append new menu
          .attr \type, \hidden
          .attr \name, \menu
          .val JSON.stringify menu)
        submit-form ev, (data) ->
          f = $ this # form
          t = $(f.find \.tooltip)
          show-tooltip t, unless data.success then (data?errors?join \<br>) else \Saved!

      # save current form on active row/input
      @$.on \blur \.row (ev) ~> @current-store!

      @$.on \click \.row (ev) ~>
        # TODO load data for active row
        @current = $ ev.target# .closest \li
        @current-restore!

      # init
      @$.find \.sortable .nested-sortable opts

    on-detach: -> @$.off!
