define = window?define or require(\amdefine) module

define (require, exports, module) ->
  require! Component: yacomponent
  {templates} = require \../build/component-jade

  module.exports =
    class AdminUpgrade extends Component
      template: templates.AdminUpgrade
