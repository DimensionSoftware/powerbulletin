(function(){
  var threshold, w, hasScrolled;
  threshold = 10;
  w = $(window);
  hasScrolled = function(){
    if (w.scrollTop() > threshold) {
      return $('body').addClass('has-scrolled');
    } else {
      return $('body').removeClass('has-scrolled');
    }
  };
  w.on('scroll', function(){
    return hasScrolled();
  });
  hasScrolled();
  $('.scroll-to-top').each(function(){
    var e;
    e = $(this);
    e.attr('title', 'Scroll to Top!');
    return e.on('mousedown', function(){
      return $('html,body').animate({
        scrollTop: $('body').offset().top
      }, 100, function(){
        return $('html,body').animate({
          scrollTop: $('body').offset().top + threshold
        }, 75, function(){
          return $('html,body').animate({
            scrollTop: $('body').offset().top
          }, 25, function(){});
        });
      });
    });
  });
}).call(this);
