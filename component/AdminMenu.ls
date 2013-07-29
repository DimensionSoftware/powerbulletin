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

      # TODO save
      @$.on \click 'input[type="submit"]' (ev) ~>
        # using generic forum submit
        # TODO serialize nested sortable
        console.log(@$.find \.sortable .data(\mjsNestedSortable).to-hierarchy!)
        # TODO submit form details for active sortable + entire nested sortable
        submit-form ev, (data) ->
          f = $ this # form
          t = $(f.find \.tooltip)
          unless data.success
            show-tooltip t, data?errors?join \<br>
          else
            show-tooltip t, \Saved!

      @$.on \click \.row (ev) ~>
        # TODO load data for row

      # init
      @$.find \.sortable .nested-sortable opts

    on-detach: -> @$.off!
