var cp = require('child_process');
var _ = require('lodash');
_.mixin(require('underscore.string'));

module.exports = function(grunt) {

  grunt.registerMultiTask('git', 'A simple API for using git via grunt', function() {
    var done = this.async();
    var options = this.options();
    var target = this.target;

    // Build out git options
    var gitOptions = _.chain(options).keys().reduce(function(memo, key) {
      memo.push('--' + _(key).dasherize());
      // Specifically allow "true" to mean "this flag has no arg with it"
      if (options[key] !== true) {
        memo.push(options[key]);
      }
      return memo;
    }, []).value();
    
    // Allow multiple tasks that run the same git command
    if (this.data.cmd) {
      var cmdArgs = this.data.cmd.split(' ');
      target = cmdArgs.shift();
      if (target === 'git') {
        target = cmdArgs.shift();
      }
      gitOptions = cmdArgs.concat(gitOptions);
    }
    
    console.log(target, gitOptions);
    // Create git process
    var gitCmd = cp.spawn('git', [target].concat(gitOptions), { stdio: this.data.stdio || 'inherit', cwd: this.data.cwd || '.' });
    gitCmd.on('close', function(code) {
      done();
    });
  });

};
