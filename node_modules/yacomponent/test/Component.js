(function(){
  var assert, Component, $, $R, _it;
  assert = require('assert');
  Component = require('../src/Component');
  $ = require('cheerio');
  $R = require('reactivejs');
  _it = it;
  describe('new Component', function(){
    var c, expected;
    c = new Component;
    describe(".template!", function(){
      return _it("should return ''", function(){
        return assert.equal('', c.template());
      });
    });
    describe(".attach!", function(){
      return _it("should return @", function(){
        return assert.equal(c.attach(), c);
      });
    });
    describe(".detach!", function(){
      return _it("should return @", function(){
        return assert.equal(c.detach(), c);
      });
    });
    describe(".locals!", function(){
      return _it("should be {}", function(){
        return assert.deepEqual({}, c.locals());
      });
    });
    describe(".html!", function(){
      var markup;
      markup = '<div class="Component"></div>';
      return _it("should return expected markup", function(){
        assert.equal(c.html(), markup);
      });
    });
    describe(".html(false)", function(){
      return _it("should return ''", function(){
        assert.equal(c.html(false), '');
      });
    });
    expected = {
      a: 1,
      b: 2
    };
    describe(".locals(" + JSON.stringify(expected) + ")", function(){
      _it("should return " + JSON.stringify(expected), function(){
        assert.deepEqual(c.locals(expected), expected);
      });
      return _it("should setup two locals: a and b", function(){
        assert.deepEqual(c.locals(), expected);
      });
    });
    describe(".locall(\\b)", function(){
      return _it("should return 2", function(){
        assert.equal(c.local('b'), 2);
      });
    });
    describe(".locall(\\foo)", function(){
      return _it("should return void", function(){
        assert.equal(c.local('foo'), void 8);
      });
    });
    describe(".locall(\\foo, 1)", function(){
      var oldFoo;
      _it("should return 1", function(){
        assert.equal(c.local('foo', 1), 1);
      });
      _it("should create a reactive state named \\foo", function(){
        var oldFoo;
        assert(c.state.foo._isReactive);
        oldFoo = c.state.foo;
      });
      _it("should create a reactive state named \\foo which resolves to 1", function(){
        assert.equal(c.state.foo(), 1);
      });
      _it("should return 2 when called again with (\\foo, 2)", function(){
        oldFoo = c.state.foo;
        assert.equal(c.local('foo', 2), 2);
      });
      return _it("should reuse the reactive state named \\foo when called again with (\\foo, 2)", function(){
        assert.equal(c.state.foo, oldFoo);
      });
    });
    return describe(".local \\reactiveFun, 1", function(){
      return _it("should throw an Error since only reactive state can be set", function(){
        c.state.reactiveFun = $R(function(){});
        return assert.throws(function(){
          return c.local('reactiveFun', 1);
        });
      });
    });
  });
  describe("new Component {} $dom", function(){
    var $dom, $container, c;
    $dom = $('<div><div/></div>');
    $container = $dom.find('div');
    c = new Component({
      render: true
    }, $container);
    describe('$dom', function(){
      _it("should be rendered to", function(){
        var markup;
        markup = '<div class="Component"></div>';
        assert.equal(markup, $dom.html());
      });
    });
  });
}).call(this);
