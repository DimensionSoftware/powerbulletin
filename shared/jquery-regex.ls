define = window?define or require(\amdefine) module
require, exports, module <- define

# tags to exclude when regexing
excludes =
  HTML   : 1
  HEAD   : 1
  STYLE  : 1
  TITLE  : 1
  META   : 1
  SCRIPT : 1
  LINK   : 1
  OBJECT : 1
  IFRAME : 1

# $.fn.regex :: jQuery plugin version of findAndReplace()
@jquery-regex-plugin = jquery-regex-plugin = ($) ->
  regex: (pattern, replacement) ->
    @each ->
      parent = this
      #console.log '<' + this.node-name + '>'

      $(this).contents().each ->
        #console.log \node-type, this.node-type
        switch this.nodeType

          # element node -> recurse to get more text nodes
          when 1
            if not excludes[this.node-name]
              #console.log '.'
              $(this).regex(pattern, replacement)

          # text node -> regex pattern replacement
          when 3
            #console.log 'x'
            html = this.data.replace(pattern, replacement)
            document = $(this)[0]._owner-document
            frag = document.create-document-fragment!
            wrap = $('<div>' + html + '</div>')[0]
            while (wrap.first-child)
              frag.append-child(wrap.first-child)
            parent.insert-before(frag, this)
            parent.remove-child(this)

            # You can stop processing by setting replacement.break to true.
            if replacement.break
              throw "BreakRequested"

@
