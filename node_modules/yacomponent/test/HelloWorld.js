(function(){
  var assert, HelloWorld, _it;
  assert = require('assert');
  HelloWorld = require('../src/HelloWorld');
  _it = it;
  describe('new HelloWorld', function(){
    var h;
    h = new HelloWorld;
    return describe(".html!", function(){
      var markup;
      markup = '<div class="HelloWorld"><p>Hello, World</p></div>';
      return _it("should return '" + markup + "'", function(){
        return assert.equal(h.html(), markup);
      });
    });
  });
  describe("new HelloWorld {locals: {name:'Matt'}}", function(){
    var h;
    h = new HelloWorld({
      locals: {
        name: 'Matt'
      }
    });
    return describe(".html!", function(){
      var markup;
      markup = '<div class="HelloWorld"><p>Hello, World</p> <strong>Matt!</strong></div>';
      return _it("should return '" + markup + "'", function(){
        return assert.equal(h.html(), markup);
      });
    });
  });
}).call(this);
