
buster.testCase('Model()', {

	"Should store the object passed into the constructor": function() {
		var model = new Model({
			foo: 'foo',
			bar: 'bar',
			baz: 'baz'
		});

		assert.equals(model.get('foo'), 'foo');
		assert.equals(model.get('bar'), 'bar');
		assert.equals(model.get('baz'), 'baz');
	}

});
