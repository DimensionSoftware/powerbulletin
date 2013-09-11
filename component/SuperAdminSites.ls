define = window?define or require(\amdefine) module
require, exports, module <- define

require \jqueryDatatables

require! Component: yacomponent
{templates} = require \../build/component-jade

module.exports =
  class SuperAdminSites extends Component
    template: templates.SuperAdminSites
    title: 'Edit Sites'
