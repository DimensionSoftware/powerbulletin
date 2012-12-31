var grunt = require('grunt');
var fs = require('fs');

exports.livescript = {
  compile: function(test) {
    'use strict';

    // test.expect(3);
debugger;
    var actual = grunt.file.read('tmp/livescript.js');
    var expected = grunt.file.read('test/expected/livescript.js');
    test.equal(expected, actual, 'should compile livescript to javascript');

    actual = grunt.file.read('tmp/concat.js');
    expected = grunt.file.read('test/expected/concat.js');
    test.equal(expected, actual, 'should compile multiple livescript files to a single javascript file');

    actual = fs.readdirSync('tmp/individual').sort();
    expected = fs.readdirSync('test/expected/individual').sort();
    test.deepEqual(expected, actual, 'should individually compile files');

    test.done();
  },
  flatten: function(test) {
    'use strict';

    test.expect(1);

    var actual = fs.readdirSync('tmp/individual_flatten').sort();
    var expected = fs.readdirSync('test/expected/individual_flatten').sort();
    test.deepEqual(expected, actual, 'should individually compile files (to flat structure)');

    test.done();
  }
};
