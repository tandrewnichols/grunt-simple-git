module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-mocha-cov');
  grunt.loadNpmTasks('grunt-travis-matrix');
  grunt.loadTasks('tasks');

  grunt.initConfig({
    jshint: {
      options: {
        reporter: require('jshint-stylish'),
        eqeqeq: true,
        es3: true,
        indent: 2,
        newcap: true,
        quotmark: 'single'
      },
      all: ['tasks/*.js']
    },
    mochacov: {
      lcov: {
        options: {
          reporter: 'mocha-lcov-reporter',
          instrument: true,
          ui: 'mocha-given',
          require: 'coffee-script/register',
          output: 'coverage/coverage.lcov'
        },
        src: ['test/helpers.coffee', 'test/**/*.coffee', '!test/acceptance.coffee'],
      },
      html: {
        options: {
          reporter: 'html-cov',
          ui: 'mocha-given',
          require: 'coffee-script/register',
          output: 'coverage/coverage.html'
        },
        src: ['test/helpers.coffee', 'test/**/*.coffee', '!test/acceptance.coffee']
      }
    },
    mochaTest: {
      options: {
        reporter: 'spec',
        ui: 'mocha-given',
        require: 'coffee-script/register'
      },
      test: {
        src: ['test/helpers.coffee', 'test/**/*.coffee']
      }
    },
    git: {
      show: {
        options: {
          s: true,
          simple: {
            rawArgs: '--format=%s',
            args: '215ef76ca4fad42f8be29b3f7fcc0d91ca491ce3',
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      },
      status: {
        options: {
          simple: {
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      },
      makeBranch: {
        options: {
          simple: {
            cmd: 'branch',
            args: 'foo',
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      },
      branch: {
        options: {
          delete: 'foo',
          simple: {
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      },
      revParse: {
        options: {
          abbrevRef: 'HEAD',
          simple: {
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      },
      log: {
        options: {
          n: '1',
          i: true,
          'grep=': 'grunt-init',
          simple: {
            onComplete: function(err, stdout, callback) {
              console.log(stdout);
              callback();
            }
          }
        }
      }
    },
    travis: {
      options: {
        targets: {
          test: '{{ version }}',
          when: 'v0.10',
          tasks: ['mochacov:lcov', 'matrix:v0.10']
        }
      }
    },
    matrix: {
      'v0.10': 'codeclimate < coverage/coverage.lcov'
    }
  });

  grunt.registerTask('mocha', ['mochaTest:test']);
  grunt.registerTask('default', ['jshint:all', 'mocha']);
  grunt.registerTask('coverage', ['mochacov:html']);
  grunt.registerTask('ci', ['jshint:all', 'mocha', 'travis']);
};
