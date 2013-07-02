require! Component: yacomponent

{templates} = require \../build/component-jade.js

module.exports =
  class AdminMenu extends Component
    template: templates.AdminMenu
