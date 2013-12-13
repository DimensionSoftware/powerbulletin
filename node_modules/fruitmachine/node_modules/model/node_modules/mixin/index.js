
'use strict';

/**
 * Locals
 */

var has = {}.hasOwnProperty;

/**
 * Exports
 */

module.exports = function(main) {
  var args = arguments;
  var l = args.length;
  var i = 0;
  var src;
  var key;

  while (++i < l) {
    src = args[i];
    for (key in src) {
      if (has.call(src, key)) {
        main[key] = src[key];
      }
    }
  }

  return main;
};
