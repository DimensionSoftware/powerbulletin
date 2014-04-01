define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent

module.exports =
  class CensorReasonDialog extends PBComponent

    init: ->

    on-attach: ->
      @$.on \click, \.onclick-close, (~> @close!)
      @$.on \click, 'input[type=submit]', (~> @submit!)

    on-detach: ->
      # TODO

    close: ->
      @detach!
      @$.remove!

    submit: ->
      reason = @$.find \textarea .val!
      $p = @local \$p
      post-id = @local \postId
      @@$.post "/resources/posts/#post-id/censor", { reason }, (r) ~>
        if r?success
          $p.add-class \censored
          @close!
      return false
