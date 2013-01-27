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
  $('#query').focus();
  $('.forum .container').masonry({
    itemSelector: '.post',
    isAnimated: true,
    isFitWidth: true,
    isResizable: true
  });
  setTimeout(function(){
    return $('.forum').waypoint({
      offset: '33%',
      handler: function(direction){
        var e, id, cur;
        e = $(this);
        id = e.attr('id');
        cur = direction === 'down'
          ? id
          : $('#' + id).prevAll('.forum:first').attr('id');
        $('header .menu').find('.active').removeClass('active');
        return $('header .menu').find("." + cur.replace(/_/, '-')).addClass('active');
      }
    });
  }, 100);
  addPostDialog = function(){
    var fid, postHtml;
    $('header').toggleClass('expanded');
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
  d.on('click', 'header', function(){
    return $('header').removeClass('expanded');
  });
  d.on('keypress', '#query', function(){
    return $('header').addClass('expanded');
  });
}).call(this);
