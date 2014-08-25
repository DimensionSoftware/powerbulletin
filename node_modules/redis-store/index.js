
/**
 * Dependencies.
 * @api private
 */
var redis = require('redis');


/**
 * Expose 'Store-redis'
 */

module.exports = function(name, options) {

	//NOTE: set options
	var client = redis.createClient();

	return function(store) {

		client.hgetall('store-redis', function(err, replies) {

			console.log('replies ola ', replies);
		});

		//set redis hashkey
		store.on('change', function(key, val) {
			client.hset(name, key, val, redis.print);
		});

	};
};

