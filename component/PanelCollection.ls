define = window?define or require(\amdefine) module
require, exports, module <- define

require! \./PBComponent
{show-tooltip} = require \../client/client-helpers

module.exports =
  class PanelCollection extends PBComponent
    # in browser repl:
    # x = PanelCollection.x()
    # x.p.select('a')
    # x.p.select('b')

    init: ->
      @list     = []
      @seen     = {}
      @selected = null
      @delay    = 100ms
      @ease-in  = \easeInExpo
      @ease-out = \easeOutExpo

      @local \selected, ''

    on-attach: ->
      @$ul      = @$.find \ul:first
      @$toggler = @$.find \.toggler

      @$toggler.click (ev) ~>
        if @$toggler.has-class \on
          @off!
        else
          @on!

      @@$R((name) ~>
        if name
          @$toggler.remove-class \off .add-class \on
        else
          @$toggler.remove-class \on .add-class \off
      ).bind-to @state.selected

    # add a panel to the collection
    add: (name, panel) ->
      if not @seen[name]
        # list
        @list.push [name, panel]
        @seen[name] = @list.length - 1
        # dom
        @$.append panel.$
        return unless panel.local \icon
        $icon = @@$ '.panel-tmpl .panel-icon' .clone!
        if n = panel.local \name # set title
          $icon.find \img .attr \title n
        $icon.find \img .attr { src: panel.local(\icon), title: panel.local(\title) }
        $icon.attr \data-user-id, panel.local(\uid)
        $icon.attr \id, "icon-#name"
        @$ul.append $icon
        $ul  = @$ul
        self = @
        $icon.find \.onclick-close .click ->
          self.remove name
          window.socket.emit \chat-mark-all-read, panel.id
          false
        $icon.click (ev) ->
          $ul.find \li .remove-class \selected
          $ @ .add-class \selected
          self.select name
        @set-notice(name, panel.local \notices)
      else
        throw "#name has already been added"

    set-notice: (id, n) ~>
      v = parse-int n
      @$.find "##id .notices"
        ..html v
        ..toggle-class \hidden (v <= 0)

    # remove a panel from the collection
    remove: (name) ~>
      i = @seen[name]
      if i?
        remove-fn = ~> # critical region
          panel = (@list.splice i, 1).0.1
          if panel.local \icon
            $icon = @$ul.find("\#icon-#{panel.local \id}")
            $icon.remove!
          $panel = @$.find(\.panel)[i]
          $panel.remove!
          # cleanup
          for key of @seen # reindex
            if @seen[key] > i then @seen[key]--
          delete @seen[name]
          panel?on-detach!
        if @selected is name
          <~ @off remove-fn # close first
        else
          remove-fn!
      else
        throw "#name has not been added."

    # find a panel by name
    find: (name) ->
      @list[@seen[name]]?1

    # make the named panel active
    select: (name) ->
      selected-panel = @find name
      $togglers      = @$.find \.panel-togglers
      if not selected-panel
        throw "#name has not been added"
      if selected-panel.exec
        return selected-panel.exec!

      set-height = -> # set height for scrolling messages
        selected-panel.$.find \.middle .css \height, (selected-panel.$.height! - 214px)

      if @selected is name
        selected-panel.hide!
        @last-selected = @selected
        @$ul.find \li .remove-class \selected
        @state.selected(@selected = null)
        $togglers .transition { left: 0 }, @delay, @ease-in, set-height
      else if @selected is null
        selected-panel.show!
        @state.selected(@selected = name)
        $togglers .transition { left: -(selected-panel.local \width) }, @delay, @ease-out, set-height
      else if @selected != name
        unselected-panel = @find @selected
        unselected-panel.hide!
        selected-panel.show!
        @state.selected(@selected = name)
        $togglers .transition { left: -(selected-panel.local \width) }, @delay, set-height
      @selected

    select-force: (name) ->
      selected-panel = @find name
      $togglers = @$.find \.panel-togglers
      if @selected != name and @selected isnt null
        unselected-panel = @find @selected
        unselected-panel.hide!
      selected-panel.show!
      $togglers .transition { left: -(selected-panel.local \width) }, @delay
      @state.selected(@selected = name)

    off: (cb=(->)) ->
      return unless @selected
      @$.find \.selected .remove-class \selected
      (@find @selected).hide!
      @last-selected = @selected
      @state.selected(@selected = null)
      $togglers = @$.find \.panel-togglers
      $togglers.transition { left: 0 }, @delay, @ease-in, cb

    on: ->
      return if @selected
      selected-panel = if @last-selected
        @find @last-selected
      else
        @default-panel
      return unless selected-panel
      $togglers = @$.find \.panel-togglers
      selected-panel.show!
      $togglers .transition { left: -(selected-panel.local \width) }, @delay, @ease-out
      @state.selected(@selected = @last-selected)

    resize: ->
      if @selected
        selected-panel = @find @selected
        selected-panel.resize!

    hide: (sel) ->
      #@@$(sel).add-class \hidden
      panel = @find @selected
      wd = panel.local \width
      @@$(sel).transition { x: wd }, @delay/2, @ease-in

    show: (sel, cb=(->)) ->
      hi = $(window).height!
      #@@$(sel).remove-class \hidden
      @@$(sel).css(height: "#{hi}px").transition { x: 0 }, @delay, @ease-out, cb

    select-force: (name) ->
      if @selected is void or @selected isnt name
        @select name

    # helper for adding a new chat panel to collection
    add-chat-panel: (opts) ->
      chat-panel = ChatPanel.chats[opts.id] = new ChatPanel locals: { opts.id, opts.icon, width: 300px, p: @ }
      @add opts.id, chat-panel

# vim:fdm=indent
