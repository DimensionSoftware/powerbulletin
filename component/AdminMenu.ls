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

    on-attach: !~>
      @$.on \click \.onclick-add (ev) ~>
        @$.find \.sortable
          ..append(@$.find \.default .clone!remove-class \default) # clone
          ..find 'li:last input' .focus!
          ..nested-sortable opts
        false
      @$.on \click \.row (ev) ~>
        # load data for row


      # init
      @$.find \.sortable .nested-sortable opts

    on-detach: -> @$.off!
