(function(){
  var win;
  win = $(window);
  win.on('scroll', function(){
    if (win.scrollTop() > 8) {
      return $('body').addClass('has-scrolled');
    } else {
      return $('body').removeClass('has-scrolled');
    }
  });
}).call(this);
