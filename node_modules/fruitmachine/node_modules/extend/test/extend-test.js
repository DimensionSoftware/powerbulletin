
buster.testCase('extend', {

	setUp: function() {
		var Animal = this.Animal = function() {};

		Animal.prototype.eat = function() {
			return 'yum yum';
		};
	},

	"Should extend the prototype of the parent object": function() {
		this.Animal.extend = extend();

		var Dog = this.Animal.extend({
			type: 'dog',
			bark: function() {
				return 'Woof!';
			}
		});

		var dog = new Dog();

		assert.equals(Dog.prototype.eat, this.Animal.prototype.eat);
		assert.equals(dog.type, 'dog');
		assert.equals(dog.eat(), 'yum yum');
		assert.equals(dog.bark(), 'Woof!');
	},

	"Should protect the given keys with an '_'": function() {
		this.Animal.extend = extend(['eat']);

		var Dog = this.Animal.extend({
			eat: function() {}
		});

		assert(Dog.prototype._eat);
		assert(Dog.prototype.eat);
	},

	"The extended class's prototype should be an instance of the original class": function() {
		this.Animal.extend = extend();

		var Dog = this.Animal.extend();

		assert(Dog.prototype instanceof this.Animal);
	}
});