(function(){
  var w, d, threshold, hasScrolled, addPostDialog, addPost;
  w = $(window);
  d = $(document);
  threshold = 10;
  hasScrolled = function(){
    var st;
    st = w.scrollTop();
    return $('body').toggleClass('has-scrolled', st > threshold);
  };
  setTimeout(function(){
    w.on('scroll', function(){
      return hasScrolled();
    });
    return hasScrolled();
  }, 1300);
  $('.scroll-to-top').each(function(){
    var e;
    e = $(this);
    e.attr('title', 'Scroll to Top!');
    return e.on('mousedown', function(){
      return $('html,body').animate({
        scrollTop: $('body').offset().top
      }, 140, function(){
        return $('html,body').animate({
          scrollTop: $('body').offset().top + threshold
        }, 110, function(){
          return $('html,body').animate({
            scrollTop: $('body').offset().top
          }, 75, function(){});
        });
      });
    });
  });
  $('#query').focus();
  $('.forum .container').masonry({
    itemSelector: '.post',
    isAnimated: true,
    isFitWidth: true,
    isResizable: true
  });
  w.resize(function(){
    return setTimeout(function(){
      return $.waypoints('refresh');
    }, 800);
  });
  setTimeout(function(){
    return $('.forum').waypoint({
      offset: '33%',
      handler: function(direction){
        var e, eId, id, prev, cur, last, next;
        e = $(this);
        eId = e.attr('id');
        id = direction === 'down'
          ? eId
          : $('#' + eId).prevAll('.forum:first').attr('id');
        prev = $('header .menu').find('.active');
        cur = $('header .menu').find("." + id.replace(/_/, '-'));
        prev.removeClass('active');
        cur.addClass('active');
        if (w.bgAnim) {
          clearTimeout(w.bgAnim);
        }
        last = $('.bg.active');
        if (!last.length) {
          next = $('#forum' + ("_bg_" + cur.data('id')));
          return next.addClass('active');
        } else {
          return w.bgAnim = setTimeout(function(){
            var next;
            next = $('#forum' + ("_bg_" + cur.data('id')));
            last.css('top', direction === 'down' ? -300 : 300);
            last.removeClass('active');
            next.addClass('active');
            next.addClass('visible');
            return w.bgAnim = 0;
          }, 300);
        }
      }
    });
  }, 100);
  addPostDialog = function(){
    var fid, postHtml;
    fid = $(this).data('fid');
    postHtml = '<h1>add post form goes here</h1>';
    return $.get('/ajax/add-post', {
      fid: fid
    }, function(html){
      $(html).dialog({
        modal: true
      });
      return false;
    });
  };
  addPost = function(){
    var form;
    form = $('#add-post-form');
    $.post('/ajax/add-post', form.serialize(), function(){
      console.log('success! post added');
      return console.log('stub: do something fancy to confirm submission');
    });
    return false;
  };
  d.on('click', '#add-post-submit', addPost);
  d.on('click', '.onclick-add-post-dialog', addPostDialog);
  d.on('click', 'header', function(e){
    if (e.target.className === 'header') {
      $('body').removeClass('expanded');
    }
    return $('#query').focus();
  });
  d.on('keypress', '#query', function(){
    return $('body').addClass('expanded');
  });
}).call(this);
