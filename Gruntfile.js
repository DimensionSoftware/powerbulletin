module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    concat: {
      options: {
        // define a string to put between each file in the concatenated output
        separator: ';'
      },
      dist: {
        src:  [], // XXX none need concat yet
        dest: 'public/js/<%= pkg.name %>.js'
      }
    },

    uglify: { // for all our js minification needs
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      dist: {
        files: {
          'public/js/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']
        }
      }
    },

    livescript: {
      compile: {
        files: {
          'app/js/main.js': 'app/main.ls'
        }
      }
    },

    watch: {
      livescript: {
        files: ['app/*.ls'],
        tasks: ['livescript'],
        options: {
          interrupt: true
        }
      }
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-livescript');

  grunt.registerTask('launch', 'Launch PowerBulletin!', function() {
    // TODO needs to work  :)
    //powerbulletin = require('./app/js/main.js')
  });

  // Default task(s).
  grunt.registerTask('default', ['livescript', 'concat', 'uglify', 'launch', 'watch']);

};
