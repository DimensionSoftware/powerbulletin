require! {
  Component: yacomponent
  ch: \../app/client-helpers.ls
}

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    template: templates.AdminMenu

    on-attach: !~>
      <~ ch.lazy-load-nested-sortable

#      $d.on \click 'html.admin .onclick-add' (ev) ->
#        console.log \add-sortable
#        false
#
