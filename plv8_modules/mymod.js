(function(){
  var foo, out$ = typeof exports != 'undefined' && exports || this;
  out$.foo = foo = function(){
    var mylst;
    return mylst = [33, 34, 77, 88, 11];
  };
}).call(this);
