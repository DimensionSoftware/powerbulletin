(function(){
  var foo, out$ = typeof exports != 'undefined' && exports || this;
  out$.foo = foo = function(){
    var mylst;
    mylst = [33, 34, 77, 88, 11];
    return plv8.execute('select * from users', []);
  };
}).call(this);
