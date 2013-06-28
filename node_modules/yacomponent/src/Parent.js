(function(){
  var Component, HelloWorld, Parent;
  Component = require('./Component');
  HelloWorld = require('./HelloWorld');
  module.exports = Parent = (function(superclass){
    var prototype = extend$((import$(Parent, superclass).displayName = 'Parent', Parent), superclass).prototype, constructor = Parent;
    prototype.template = function(){
      return "<div class=\"Parent-hw\"></div>";
    };
    prototype.init = function(){
      return this.children = {
        hw: new HelloWorld({}, '.Parent-hw', this)
      };
    };
    prototype.onAttach = function(){
      return $(document).on('click', this.selector(function(){
        return alert('say my name say my name, you acting kinda shady aint callin me baby why the sudden change?');
      }));
    };
    prototype.onDetach = function(){
      $(document).off('click', this.selector);
    };
    function Parent(){
      Parent.superclass.apply(this, arguments);
    }
    return Parent;
  }(Component));
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
