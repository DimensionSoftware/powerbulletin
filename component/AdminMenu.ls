require! {
  Component: yacomponent
  ch: \../app/client-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    opts =
      handle: \div
      items:  \li
      max-levels: 2
      tolerance: \pointer
      tolerance-element: '> div'
      placeholder: \placeholder

    template: templates.AdminMenu

    init: !~>
     # TODO pre-load nested sortable list + initial active sortable
     # - safely assume 2 levels max for now)
     #for item in site.menu
     #  for sub-item in item.menu

    on-attach: !~>
      @$.on \click \.onclick-add (ev) ~>
        @$.find \.col2 .show 300ms # display options

        const prefix = \list_
        s   = @$.find \.sortable

        # generate id & add new menu item!
        max = parse-int maximum(s.find \li |> map (-> it.id.replace prefix, ''))
        id  = unless max then 1 else max+1
        s
          ..append(@$.find \.default .clone!remove-class(\default).attr \id, "#prefix#id") # clone
          ..find 'li:last input' .focus!
          ..nested-sortable opts
        false

      # save menu
      @$.on \click 'button[type="submit"]' (ev) ~>
        menu = @$.find \.sortable .data(\mjsNestedSortable).to-hierarchy! # extended to pull data attributes, too
        f = @$.find \form
        f.find 'input[name="menu"]' .remove! # prune last
        console.log menu
        f.append(@@$ \<input>                # append new
          .attr \type, \hidden
          .attr \name, \menu
          .val JSON.stringify menu)
        submit-form ev, (data) ->
          f = $ this # form
          t = $(f.find \.tooltip)
          show-tooltip t, unless data.success then (data?errors?join \<br>) else \Saved!

      @$.on \blur \.row (ev) ~>
        # TODO save current form on active row/input

      @$.on \click \.row (ev) ~>
        # TODO load data for active row

      # init
      @$.find \.sortable .nested-sortable opts

    on-detach: -> @$.off!
