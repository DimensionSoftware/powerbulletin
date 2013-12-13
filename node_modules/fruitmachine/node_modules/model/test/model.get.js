
buster.testCase('Model#get()', {

  "Should be able to get data by key": function() {
    var model = new Model();
    var key = 'myKey';
    var value = 'myValue';

    model.set(key, value);

    assert.equals(model.get(key), value);
  },

  "Should return undefined if a key does not exist": function() {
    var model = new Model({ foo: 'bar' });
    var result = model.get('baz');

    assert.equals(typeof result, 'undefined');
  },

  "Should return entire source data object if no key is given": function() {
    var data = { foo: 'bar' };
    var model = new Model(data);
    var result = model.get();

    assert.equals(result, data);
  },

  "Should return the objects value even when the key is numeric, particularly the falsey value '0'": function() {
    var data = { 0: 'foo', 1: 'bar' };
    var model = new Model(data);

    assert.equals(model.get(0), 'foo');
    assert.equals(model.get(1), 'bar');
  }

});
