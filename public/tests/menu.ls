$ ->
  # get menu
  menu = $ \#menu
  rows = menu.find '> .row > a'

  intent-timer = null
  remove-hover = -> rows.remove-class \hover

  # delegates
  rows.on \mouseenter -> # set hover
    clear-timeout intent-timer
    remove-hover!
    r = $ this .add-class \hover # row
    # TODO intelligently reposition submenu
    s = r.next \.submenu
    ro = r.offset!left
    so = s.offset!left
    s.css \left, 10

    console.log \r:, r.offset!left
    console.log \s:, s.offset!left
    #console.log s.position!left
  menu.on \mouseleave -> # mouse-hover-intent'd out
    intent-timer := set-timeout (->
      remove-hover!
      menu.find \.active .add-class \hover), 400ms
