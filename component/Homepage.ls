define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  \./PBComponent
  \./Pins
  \./MenuSummary
}

{show-info, storage} = require \../client/client-helpers if window?

# XXX rename Homepage -> Layout-Split-Horizontal?

module.exports =
  class Homepage extends PBComponent
    init: ->
      # add children
      @children =
        #pins:    new Pins {locals:@locals!} \.Pins @
        summary: new MenuSummary {locals:@locals!} \.MenuSummary @

    on-attach: ->
      if u = window.user
        const seen-intro = "#{u.id}-home-intro" # key
        unless storage.get seen-intro
          storage.set seen-intro, true
          help = []
          help.push ['.Homepage, .menu .row', '<b>Welcome!</b><br/>Forum Activity Shows Here in Realtime']
          help.push -> $ \header .css \z-index, 202 # lift it up
          help.push ['.tools', '''
            Start Building Your Community!
            <br/>
            <small><i>Hover Over Your Profile Photo to the Admin</i></small>
          ''', -1] if user.rights.super
          help.push -> $ \header .css \z-index, 200 # put it back
          show-info 0, ...help

# vim: fdm=marker
