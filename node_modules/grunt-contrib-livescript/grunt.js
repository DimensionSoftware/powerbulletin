/*
 * grunt-contrib-livescript
 * http://gruntjs.com/
 *
 * Copyright (c) 2012 David Souther, contributors
 * Licensed under the MIT license.
 */

module.exports = function(grunt) {
  'use strict';

  // Project configuration.
  grunt.initConfig({
    lint: {
       // all: ['grunt.js', 'tasks/*.js', '<config:nodeunit.tasks>']
      all: []
    },

    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true,
        es5: true
      }
    },

    // Before generating any new files, remove any previously-created files.
    clean: {
      test: ['tmp']
    },

    // Configuration to be run (and then tested).
    livescript: {
      options: {
        bare: true
      },
      compile: {
        files: {
          'tmp/livescript.js': ['test/fixtures/livescript1.ls'],
          'tmp/concat.js': ['test/fixtures/livescript1.ls', 'test/fixtures/livescript2.ls'],
          'tmp/individual/*.js': ['test/fixtures/livescript1.ls', 'test/fixtures/livescript2.ls', 'test/fixtures/level2/livescript3.ls']
        }
      },
      flatten: {
        files: {
          'tmp/individual_flatten/*.js': ['test/fixtures/livescript1.ls', 'test/fixtures/livescript2.ls', 'test/fixtures/level2/livescript3.ls']
        },
        options: {
          flatten: true
        }
      }
    },

    // Unit tests.
    nodeunit: {
      tasks: ['test/*_test.js']
    }
  });

  // Actually load this plugin's task(s).
  grunt.loadTasks('tasks');

  // The clean plugin helps in testing.
  grunt.loadNpmTasks('grunt-contrib-clean');

  // Whenever the 'test' task is run, first clean the 'tmp' dir, then run this
  // plugin's task(s), then test the result.
  grunt.renameTask('test', 'nodeunit');
  grunt.registerTask('test', 'clean livescript nodeunit');

  // By default, lint and run all tests.
  grunt.registerTask('default', 'lint test');
};
