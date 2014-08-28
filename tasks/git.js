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
    var gitOptions = _(options).omit('cwd', 'stdio', 'force').keys().reduce(function(memo, key) {
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
    }, []);

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
    var opts = { cwd: options.cwd || process.cwd(), stdio: options.stdio || 'inherit' };
    if (options.stdio === false) delete opts.stdio; 
    var gitCmd = cp.spawn('git', [target].concat(gitOptions), opts);

    // Listen if we have emitters and stdio is not false
    if (gitCmd.stdout && options.stdio !== false) {
      gitCmd.stdout.on('data', function(data) {
        grunt.log.writeln(data.toString());
      });
    }
    if (gitCmd.stderr && options.stdio !== false) {
      gitCmd.stderr.on('data', function(data) {
        grunt.log.writeln(data.toString());
      });
    }

    gitCmd.on('close', (function(__this) {
      return function(code) {
        if (options.force && code) {
          grunt.log.writeln('git:' + __this.target + ' returned code ' + code + '. Ignoring...');
          done(0);
        } else done(code);
      };
    })(this));
  });
};
