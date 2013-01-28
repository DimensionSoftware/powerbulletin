

/**
 * hasOwnProperty.
 */

var has = Object.prototype.hasOwnProperty;

/**
 * Require the given path.
 *
 * @param {String} path
 * @return {Object} exports
 * @api public
 */

function require(path, parent, orig) {
  var resolved = require.resolve(path);

  // lookup failed
  if (null == resolved) {
    orig = orig || path;
    parent = parent || 'root';
    var err = new Error('Failed to require "' + orig + '" from "' + parent + '"');
    err.path = orig;
    err.parent = parent;
    err.require = true;
    throw err;
  }

  var module = require.modules[resolved];

  // perform real require()
  // by invoking the module's
  // registered function
  if (!module.exports) {
    module.exports = {};
    module.client = module.component = true;
    module.call(this, module.exports, require.relative(resolved), module);
  }

  return module.exports;
}

/**
 * Registered modules.
 */

require.modules = {};

/**
 * Registered aliases.
 */

require.aliases = {};

/**
 * Resolve `path`.
 *
 * Lookup:
 *
 *   - PATH/index.js
 *   - PATH.js
 *   - PATH
 *
 * @param {String} path
 * @return {String} path or null
 * @api private
 */

require.resolve = function(path) {
  var index = path + '/index.js';

  var paths = [
    path,
    path + '.js',
    path + '.json',
    path + '/index.js',
    path + '/index.json'
  ];

  for (var i = 0; i < paths.length; i++) {
    var path = paths[i];
    if (has.call(require.modules, path)) return path;
  }

  if (has.call(require.aliases, index)) {
    return require.aliases[index];
  }
};

/**
 * Normalize `path` relative to the current path.
 *
 * @param {String} curr
 * @param {String} path
 * @return {String}
 * @api private
 */

require.normalize = function(curr, path) {
  var segs = [];

  if ('.' != path.charAt(0)) return path;

  curr = curr.split('/');
  path = path.split('/');

  for (var i = 0; i < path.length; ++i) {
    if ('..' == path[i]) {
      curr.pop();
    } else if ('.' != path[i] && '' != path[i]) {
      segs.push(path[i]);
    }
  }

  return curr.concat(segs).join('/');
};

/**
 * Register module at `path` with callback `definition`.
 *
 * @param {String} path
 * @param {Function} definition
 * @api private
 */

require.register = function(path, definition) {
  require.modules[path] = definition;
};

/**
 * Alias a module definition.
 *
 * @param {String} from
 * @param {String} to
 * @api private
 */

require.alias = function(from, to) {
  if (!has.call(require.modules, from)) {
    throw new Error('Failed to alias "' + from + '", it does not exist');
  }
  require.aliases[to] = from;
};

/**
 * Return a require function relative to the `parent` path.
 *
 * @param {String} parent
 * @return {Function}
 * @api private
 */

require.relative = function(parent) {
  var p = require.normalize(parent, '..');

  /**
   * lastIndexOf helper.
   */

  function lastIndexOf(arr, obj) {
    var i = arr.length;
    while (i--) {
      if (arr[i] === obj) return i;
    }
    return -1;
  }

  /**
   * The relative require() itself.
   */

  function localRequire(path) {
    var resolved = localRequire.resolve(path);
    return require(resolved, parent, path);
  }

  /**
   * Resolve relative to the parent.
   */

  localRequire.resolve = function(path) {
    // resolve deps by returning
    // the dep in the nearest "deps"
    // directory
    if ('.' != path.charAt(0)) {
      var segs = parent.split('/');
      var i = lastIndexOf(segs, 'deps') + 1;
      if (!i) i = 0;
      path = segs.slice(0, i + 1).join('/') + '/deps/' + path;
      return path;
    }
    return require.normalize(p, path);
  };

  /**
   * Check if module is defined at `path`.
   */

  localRequire.exists = function(path) {
    return has.call(require.modules, localRequire.resolve(path));
  };

  return localRequire;
};
require.register("add-post/index.js", function(exports, require, module){
// from add-post component

});
require.register("pb-entry/index.js", function(exports, require, module){
(function(){
  var w, d, threshold, hasScrolled, addPostDialog, addPost;
  require()({
    addPost: '../add-post',
    v: '../validations'
  });
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

});
require.alias("add-post/index.js", "pb-entry/deps/add-post/index.js");

