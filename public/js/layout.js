(function(){
  var threshold, w, hasScrolled;
  threshold = 10;
  w = $(window);
  hasScrolled = function(){
    var st;
    st = w.scrollTop();
    return $('body').toggleClass('has-scrolled', st > threshold);
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
        }, 85, function(){
          return $('html,body').animate({
            scrollTop: $('body').offset().top
          }, 35, function(){});
        });
      });
    });
  });
}).call(this);
