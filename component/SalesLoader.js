// Generated by LiveScript 1.2.0
(function(){
  var define;
  define = (typeof window != 'undefined' && window !== null ? window.define : void 8) || require('amdefine')(module);
  define(function(require, exports, module){
    var Component, SalesApp, Auth, templates, SalesLoader;
    Component = require('yacomponent');
    SalesApp = require('./SalesApp');
    Auth = require('./Auth');
    templates = require('../build/component-jade').templates;
    return module.exports = SalesLoader = (function(superclass){
      var prototype = extend$((import$(SalesLoader, superclass).displayName = 'SalesLoader', SalesLoader), superclass).prototype, constructor = SalesLoader;
      prototype.template = templates.SalesLoader;
      prototype.init = function(){
        return this.children = {
          sales: new SalesApp({}, 'body', this)
        };
      };
      function SalesLoader(){
        SalesLoader.superclass.apply(this, arguments);
      }
      return SalesLoader;
    }(Component));
  });
  function extend$(sub, sup){
    function fun(){} fun.prototype = (sub.superclass = sup).prototype;
    (sub.prototype = new fun).constructor = sub;
    if (typeof sup.extended == 'function') sup.extended(sub);
    return sub;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);