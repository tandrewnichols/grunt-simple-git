var cp = require('child_process');
var _ = require('lodash');
_.mixin(require('underscore.string'));

module.exports = function(grunt) {
  grunt.registerMultiTask('git', 'A simple API for using git via grunt', function() {
    var done = this.async();
    var options = this.options();
    var target = _.dasherize(this.target);
    var flag = [];
    var nonFlag = [];

    // Build out git options
    var gitOptions = _.chain(options).keys().reduce(function(memo, key) {
      // Allow short options
      if (key.length === 1) {
        if (options[key] === true) flag.push(key);
        else nonFlag.push(key);
      } else {
        if (_.endsWith(key, '=')) {
          memo.push('--' + _.dasherize(key) + options[key]);
        } else {
          memo.push('--' + _.dasherize(key));
          // Specifically allow "true" to mean "this flag has no arg with it"
          if (options[key] !== true) memo.push(options[key]);
        }
      }
      return memo;
    }, []).value();

    // Collect short options
    if (flag.length) gitOptions.push('-' + flag.join(''));
    _.each(nonFlag, function(k) {
      gitOptions = gitOptions.concat([ '-' + k, options[k] ]);
    });
    
    // Allow multiple tasks that run the same git command
    if (this.data.cmd) {
      var cmdArgs = this.data.cmd.split(' ');
      target = cmdArgs.shift();
      if (target === 'git') target = cmdArgs.shift();
      gitOptions = cmdArgs.concat(gitOptions);
    }

    if (this.data.rawArgs) gitOptions = gitOptions.concat(this.data.rawArgs);
    
    // Create git process
    var gitCmd = cp.spawn('git', [target].concat(gitOptions), { stdio: this.data.stdio || 'inherit', cwd: this.data.cwd || '.' });
    gitCmd.on('close', function(code) {
      done();
    });
  });
};
