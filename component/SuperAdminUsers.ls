define = window?define or require(\amdefine) module
require, exports, module <- define

require! Component: yacomponent
{templates} = require \../build/component-jade

module.exports =
  class SuperAdminUsers extends Component
    template: templates.SuperAdminUsers
    title: 'Edit Users'
