var cli = require('simple-cli');

module.exports = function(grunt) {
  grunt.registerMultiTask('git', 'A simple API for using git via grunt', function() {
    cli.spawn(grunt, this, 'git', this.async());
  });
};
