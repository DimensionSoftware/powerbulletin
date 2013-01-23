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
  $('.content .container').masonry({
    itemSelector: '.topic',
    isAnimated: true,
    isFitWidth: true,
    isResizable: true
  });
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
      return console.log('STUB: do something fancy to confirm submission');
    });
    return false;
  };
  d.on('click', '#add-post-submit', addPost);
  d.on('click', '.onclick-add-post-dialog', addPostDialog);
}).call(this);
