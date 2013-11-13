define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  Component: yacomponent
}
{templates}    = require \../build/component-jade
{show-tooltip} = require \../client/client-helpers

module.exports =
  class PanelCollection extends Component
    template: templates.PanelCollection

    init: ->
      @list     = []
      @seen     = {}
      @selected = null
      @$ul      = @$.find('ul:first')

    on-attach: ->

    # add a panel to the collection
    add: (name, panel) ->
      if not @seen[name]
        # list
        @list.push [name, panel]
        @seen[name] = @list.length - 1
        # dom
        $icon = @$ '<li class="panel-icon"><img title="" /></li>'
        $icon.find 'img' .attr { src: panel.icon, title: panel.title }
        @$ul.append $icon
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
        $icon.remove!
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
        $togglers .animate { left: -selected-panel.width }, @delay, @ease-out
      else if @selected != name
        unselected-panel = @find @selected
        unselected-panel.hide!
        selected-panel.show!
        $togglers .animate { left: -selected-panel.width }, @delay
        @selected = name
      @selected

    resize: ->
      if @selected
        selected-panel = @find @selected
        selected-panel.resize!

    show: ->

    hide: ->

