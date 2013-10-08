(function(){
  $(function(){
    var menu, rows, intentTimer, removeHover;
    menu = $('#menu');
    rows = menu.find('> .row > a');
    intentTimer = null;
    removeHover = function(){
      return rows.removeClass('hover');
    };
    rows.on('mouseenter', function(){
      var r, s, ro, so;
      clearTimeout(intentTimer);
      removeHover();
      r = $(this).addClass('hover');
      s = r.next('.submenu');
      ro = r.offset().left;
      so = s.offset().left;
      s.css('left', 10);
      console.log('r:', r.offset().left);
      return console.log('s:', s.offset().left);
    });
    return menu.on('mouseleave', function(){
      return intentTimer = setTimeout(function(){
        removeHover();
        return menu.find('.active').addClass('hover');
      }, 400);
    });
  });
}).call(this);
