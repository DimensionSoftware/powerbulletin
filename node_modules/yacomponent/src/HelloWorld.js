(function(){
  var Component, HelloWorld;
  Component = require('./Component');
  module.exports = HelloWorld = (function(superclass){
    var prototype = extend$((import$(HelloWorld, superclass).displayName = 'HelloWorld', HelloWorld), superclass).prototype, constructor = HelloWorld;
    prototype.template = function(arg$){
      var name;
      name = (arg$ != null
        ? arg$
        : {}).name;
      return "<p>Hello, World</p>" + (name ? ' <strong>' + name + '</strong>' : '');
    };
    prototype.mutate = function($dom){
      var $strong;
      $strong = $dom.find('strong');
      $strong.text($strong.text() + "!");
    };
    prototype.onAttach = function(){
      return this.$.on('click', 'p', function(){
        return alert('say my name say my name, you acting kinda shady aint callin me baby why the sudden change?');
      });
    };
    prototype.onDetach = function(){
      return this.$.off('click', 'p');
    };
    function HelloWorld(){
      HelloWorld.superclass.apply(this, arguments);
    }
    return HelloWorld;
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
