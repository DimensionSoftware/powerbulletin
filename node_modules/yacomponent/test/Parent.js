(function(){
  var assert, Parent, _it;
  assert = require('assert');
  Parent = require('../src/Parent');
  _it = it;
  describe('new Parent', function(){
    var p;
    p = new Parent;
    return describe(".html!", function(){
      var markup;
      markup = '<div class="Parent"><div class="Parent-hw HelloWorld"><p>Hello, World</p></div></div>';
      _it("should return '" + markup + "'", function(){
        return assert.equal(p.html(), markup);
      });
      return _it("should return '" + markup + "' after calling render!", function(){
        p.render();
        return assert.equal(p.html(), markup);
      });
    });
  });
}).call(this);
