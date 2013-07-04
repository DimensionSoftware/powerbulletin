require! {
  Component: yacomponent
  ch: \../app/client-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    template: templates.AdminMenu

    on-attach: !~>
      @$.on \click \.onclick-add (ev) ~>
        console.log \add-sortable
        false

      # init
      <~ ch.lazy-load-nested-sortable
      $ \.sortable .nested-sortable {
        handle: \div
        items:  \li
        tolerance-element: '> div'}

    on-detach: -> @$.off!
