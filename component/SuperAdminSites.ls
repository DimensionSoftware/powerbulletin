define = window?define or require(\amdefine) module
require, exports, module <- define

require \jqueryDatatables

require! Component: yacomponent
{templates} = require \../build/component-jade

module.exports =
  class SuperAdminSites extends Component
    template: templates.SuperAdminSites
    title: 'Edit Sites'
    attach: ->
      if @is-client
        @dt = @$.find(\table.SuperAdminSites-datatable).data-table {
          ao-columns:
            * {m-data: \id}
            * {m-data: \name}
            * {m-data: \email}
            * {m-data: \rights}
            * {m-data: \verified}
            * {m-data: \photo}
          b-processing: true
          b-server-side: true
          s-ajax-source: \/resources/users
        }
