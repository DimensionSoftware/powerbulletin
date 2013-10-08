$ ->
  # get menu
  menu = $ \#menu
  rows = menu.find '> .row > a'

  intent-timer = void
  remove-hover = -> rows.remove-class \hover

  # delegates
  rows.on \mouseenter -> # set hover
    clear-timeout intent-timer
    remove-hover!
    r  = $ this .add-class \hover # row
    s  = r.next \.submenu         # row's menu

    # precalc
    w  = $ window .width!
    ds = w - (s.offset!left + s.width!)
    if ds < 0 # intelligently reposition submenu
      set-timeout (-> s.transition {left:ds}, 200ms, \easeOutExpo), 200ms

  menu.on \mouseleave -> # mouse-hover-intent'd out
    intent-timer := set-timeout (->
      remove-hover!
      menu.find \.active .add-class \hover), 400ms
