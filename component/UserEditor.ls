define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

module.exports =
  class UserEditor extends PBComponent
    on-attach: ->
      c = @
      dollarish = @@$
      @$.on \submit \form ->
        $form = dollarish @
        data = $form.serialize!
        $.ajax {
          type: \PUT
          url: "/resources/users/#{c.local(\user).id}"
          data: $form.serialize!
        }
        false
# vim:fdm=marker
