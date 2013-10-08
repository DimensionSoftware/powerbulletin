(function(){
  $(function(){
    var menu, rows, intentTimer, removeHover;
    menu = $('#menu');
    rows = menu.find('> .row > a');
    intentTimer = void 8;
    removeHover = function(){
      return rows.removeClass('hover');
    };
    rows.on('mouseenter', function(){
      var r, s, w, ds;
      clearTimeout(intentTimer);
      removeHover();
      r = $(this).addClass('hover');
      s = r.next('.submenu');
      w = $(window).width();
      ds = w - (s.offset().left + s.width());
      if (ds < 0) {
        return setTimeout(function(){
          return s.transition({
            left: ds
          }, 200, 'easeOutExpo');
        }, 200);
      }
    });
    return menu.on('mouseleave', function(){
      return intentTimer = setTimeout(function(){
        removeHover();
        return menu.find('.active').addClass('hover');
      }, 400);
    });
  });
}).call(this);
