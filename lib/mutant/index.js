var define;
define = (typeof window != 'undefined' && window !== null ? window.define : void 8) || require('amdefine')(module);
define(function(require, exports, module){
  module.exports = require('./mutant')
});
