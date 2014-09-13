var plugin = require('..'),
    Store = require('store-component'),
    redis = require('redis'),
    assert = require('assert');

var client = redis.createClient();

describe("Initialization", function() {
  var store;
  beforeEach(function() {
    // client.hset('store-redis', 'repo', 'store', redis.print);
    // client.hset('store-redis', 'name', 'olivier', redis.print);
    store = new Store();
    store.use(plugin('store-redis'));
  });

  // afterEach(function() {
  //   client.hdel('store-redis', 'repo');
  //   client.hdel('store-redis', 'name');    
  // });
  
  it("should initialize store with redis hkeys", function() {
    assert.equal(store.get('repo'), 'store');
    assert.equal(store.get('name'), 'olivier');
  });
  
});


// describe("Hashkey", function() {
//   var store;
//   beforeEach(function() {
//     store = new Store();
//     store.use(plugin('store-redis'));
//   });
  
//   it("should set hash key", function(done) {

//     store.set('repo', 'store');
//     client.hkeys("store-redis", function (err, replies) {
//       client.hget('store-redis', 'repo', function(err, res) {
//         if(res === 'store') done();
//       });
//     });

//   });

//   it('should del hash key', function(done) {
//     store.del('repo');
//     client.hget('store-redis', 'repo', function(req, res) {
//       console.log('del', arguments);
//     });
//   });

//   it('should update store on hash key', function() {

//   });
  
// });
