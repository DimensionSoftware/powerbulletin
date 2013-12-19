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
    @x = ->
      p = new PanelCollection
      $('body').append p.$
      a = new ChatPanel({locals: { id: 'a', icon: 'https://muscache.pb.com/images/twitter_32.png', width: 300px, css: { background: '#544', opacity: 0.85 }, p: p}})
      p.add 'a', a
      b = new ChatPanel({locals: { id: 'b', icon: 'https://muscache.pb.com/images/twitter_32.png', width: 400px, css: { background: '#88c', opacity: 0.75 }, p: p}})
      p.add 'b', b
      {p, a, b}

    init: ->
      @list     = []
      @seen     = {}
      @selected = null
      @delay    = 250ms
      @ease-in  = \easeInBack
      @ease-out = \easeOutBack

      @local \selected, ''

    on-attach: ->
      @$ul = @$.find('ul:first')
      @$toggler = @$.find('.toggler')

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
        $icon = @@$ '<li class="panel-icon photo"><img title="" /></li>'
        $icon.find 'img' .attr { src: panel.local(\icon), title: panel.local(\title) }
        @$ul.append $icon
        @$.append panel.$
        $ul = @$ul
        self = @
        $icon.click (ev) ->
          $ul.find \li .remove-class \selected
          $(@).add-class \selected
          self.select name
      else
        throw "#name has already been added"

    # remove a panel from the collection
    remove: (name) ->
      i = @seen[name]
      if i
        @list.splice i, 1
        delete @seen[name]
        $icon = @$ul.find('li')[i]
        $panel = @$.find('.panel')[i]
        $icon.remove!
        $panel.remove!
        for key in this.seen
          if @seen[key] > i then @seen[key]--
      else
        throw "#name has not been added."

    # find a panel by name
    find: (name) ->
      @list[@seen[name]][1]

    # make the named panel active
    select: (name) ->
      selected-panel = @find name
      if not selected-panel
        throw "#name has not been added"
      if selected-panel.exec
        return selected-panel.exec!

      $togglers = @$.find \.panel-togglers
      if @selected is name
        selected-panel.hide!
        @last-selected = @selected
        @$ul.find \li .remove-class \selected
        @state.selected(@selected = null)
        $togglers .animate { left: 0 }, @delay, @ease-in
      else if @selected is null
        selected-panel.show!
        @state.selected(@selected = name)
        $togglers .animate { left: -(selected-panel.local \width) }, @delay, @ease-out
      else if @selected != name
        unselected-panel = @find @selected
        unselected-panel.hide!
        selected-panel.show!
        @state.selected(@selected = name)
        $togglers .animate { left: -(selected-panel.local \width) }, @delay
      @selected

    select-force: (name) ->
      selected-panel = @find name
      $togglers = @$.find \.panel-togglers
      if @selected != name and @selected isnt null
        unselected-panel = @find @selected
        unselected-panel.hide!
      selected-panel.show!
      $togglers .animate { left: -(selected-panel.local \width) }, @delay
      @state.selected(@selected = name)

    off: ->
      return unless  @selected
      (@find @selected).hide!
      @last-selected = @selected
      @state.selected(@selected = null)
      $togglers = @$.find \.panel-togglers
      $togglers .animate { left: 0 }, @delay, @ease-in

    on: ->
      return if @selected
      selected-panel = if @last-selected
        @find @last-selected
      else
        @default-panel
      return unless selected-panel
      $togglers = @$.find \.panel-togglers
      selected-panel.show!
      $togglers .animate { left: -(selected-panel.local \width) }, @delay, @ease-out
      @state.selected(@selected = @last-selected)

    resize: ->
      if @selected
        selected-panel = @find @selected
        selected-panel.resize!

    hide: (sel) ->
      #@@$(sel).add-class \hidden
      @@$(sel).hide(@delay, @ease-in)

    show: (sel) ->
      hi = $(window).height!
      #@@$(sel).remove-class \hidden
      @@$(sel).css(height: "#{hi}px").show @delay, @ease-out

    select-force: (name) ->
      if @selected is null or @selected isnt name
        @select name

    # helper for adding a new chat panel to collection
    add-chat-panel: (opts) ->
      console.warn opts
      chat-panel = new ChatPanel locals: { opts.id, opts.icon, width: 300px, css: { background: '#fff', opacity: 0.85 }, p: @ }
      @add opts.id, chat-panel

# vim:fdm=indent
