
# XXX layout-specific client-side

win = $ window

win.on 'scroll' ->
  if win.scrollTop! > 8
    $ 'body' .add-class 'has-scrolled'
  else
    $ 'body' .remove-class 'has-scrolled'
