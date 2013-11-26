define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates}    = require \../build/component-jade
{show-tooltip} = require \../client/client-helpers

module.exports =
  class PanelCollection extends Component
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

    template: templates.PanelCollection

    init: ->
      @list     = []
      @seen     = {}
      @selected = null
      @delay    = 250ms
      @ease-in  = \easeInBack
      @ease-out = \easeOutBack

    on-attach: ->
      @$ul      = @$.find('ul:first')

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
        @selected = null
        @$ul.find \li .remove-class \selected
        $togglers .animate { left: 0 }, @delay, @ease-in
      else if @selected is null
        selected-panel.show!
        $togglers .animate { left: -(selected-panel.local \width) }, @delay, @ease-out
        @selected = name
      else if @selected != name
        unselected-panel = @find @selected
        unselected-panel.hide!
        selected-panel.show!
        $togglers .animate { left: -(selected-panel.local \width) }, @delay
        @selected = name
      @selected

    select-force: (name) ->
      console.log name
      selected-panel = @find name
      $togglers = @$.find \.panel-togglers
      if @selected != name and @selected isnt null
        unselected-panel = @find @selected
        unselected-panel.hide!
      selected-panel.show!
      $togglers .animate { left: -(selected-panel.local \width) }, @delay
      @selected = name

    resize: ->
      if @selected
        selected-panel = @find @selected
        selected-panel.resize!

    hide: (sel) ->
      @@$(sel).add-class \hidden
      @@$(sel).hide(@delay, @ease-in)

    show: (sel) ->
      hi = $(window).height!
      @@$(sel).remove-class \hidden
      @@$(sel).css(height: "#{hi}px").show @delay, @ease-out

# vim:fdm=indent
