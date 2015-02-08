[![Build Status](https://travis-ci.org/tandrewnichols/grunt-simple-git.png)](https://travis-ci.org/tandrewnichols/grunt-simple-git) [![downloads](http://img.shields.io/npm/dm/grunt-simple-git.svg)](https://npmjs.org/package/grunt-simple-git) [![npm](http://img.shields.io/npm/v/grunt-simple-git.svg)](https://npmjs.org/package/grunt-simple-git) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-simple-git/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-simple-git) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-simple-git/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-simple-git) [![dependencies](https://david-dm.org/tandrewnichols/grunt-simple-git.png)](https://david-dm.org/tandrewnichols/grunt-simple-git)

[![NPM info](https://nodei.co/npm/grunt-simple-git.png?downloads=true)](https://nodei.co/npm/grunt-simple-git.png?downloads=true)

# grunt-simple-git

A simple API for using git via grunt

## Getting Started

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-simple-git --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with:

```javascript
grunt.loadNpmTasks('grunt-simple-git');
```

Alternatively, install and use [task-master](https://github.com/tandrewnichols/task-master), and it will handle this for you.

## The "git" task

This plugin uses the [simple-cli](https://github.com/tandrewnichols/simple-cli) interface, so any of the options avaiable there will work with this plugin. A summary of the more salient points are included below.

### Overview

The `git` task is a multiTask, where the target is (usually) the git command to run. Options to git can be supplied in the options object, and there are various options supported by the library itself which must be under `options.simple`.

### Git Options

Generally speaking, options are supplied as camel-cased equivalents of the command line options. Specifically, you can do any/all of the following:

#### Long options

```js
grunt.initConfig({
  git: {
    commit: {
      options: {
        message: '"Fix stuff"'
      }
    }
  }
});
```

This will run `git commit --message "Fix stuff"`

#### Boolean options

```js
grunt.initConfig({
  git: {
    status: {
      options: {
        short: true
      }
    }
  }
});
```

This will run `git status --short`

#### Multi-word options

```js
grunt.initConfig({
  git: {
    diff: {
      options: {
        nameOnly: true
      }
    }
  }
});
```

This will run `git diff --name-only`

#### Short options

```js
grunt.initConfig({
  git: {
    commit: {
      options: {
        m: '"Fix stuff"'
      }
    }
  }
});
```

This will run `git commit -m "Fix stuff"`

#### Short boolean options

```js
grunt.initConfig({
  git: {
    status: {
      options: {
        s: true
      }
    }
  }
});
```

This will run `git status -s`

#### Multiple short options grouped together

```js
grunt.initConfig({
  git: {
    commit: {
      options: {
        a: true,
        n: true,
        m: '"Fix stuff"'
      }
    }
  }
});
```

This will run `git commit -an -m "Fix stuff"`

#### Options with equal signs

```js
grunt.initConfig({
  git: {
    show: {
      options: {
        'format=': 'short'
      }
    }
  }
});
```

This will run `git show --format=short`

#### Arrays of options

I couldn't find a legitimate git command that would use this, but if such a thing exists, it would work.

```js
grunt.initConfig({
  git: {
    fake: {
      options: {
        a: ['foo', 'bar'],
        greeting: ['hello', 'goodbye']
      }
    }
  }
});
```

This will run `git fake -a foo -a bar --greeting hello --greeting goodbye`, which, as previously mentioned, is nothing.

### Task Options

Simple cli can be configured by specifying any of the following options under `options.simple`.

#### env

Supply additional environment variables to the child process.

```js
grunt.initConfig({
  git: {
    status: {
      options: {
        simple: {
          env: {
            FOO: 'bar'
          }
        }
      }
    }
  }
});
```

#### cwd

Set the current working directory for the child process.

```js
grunt.initConfig({
  git: {
    status: {
      options: {
        simple: {
          cwd: './test'
        }
      }
    }
  }
});
```

#### force

If the task fails, don't halt the entire task chain.

```js
grunt.initConfig({
  git: {
    status: {
      options: {
        simple: {
          force: true
        }
      }
    }
  }
});
```

#### onComplete

A callback to handle the stdout and stderr streams. `simple-cli` aggregates the stdout and stderr data output and will supply the final strings to the `onComplete` function. This function should have the signature `function(err, stdout, callback)` where `err` is an error object containing the stderr stream (if any errors were reported) and the code returned by the child process (as `err.code`), `stdout` is a string, and `callback` is a function. The callback must be called with a falsy value to complete the task (calling it with a truthy value - e.g. `1` - will fail the task).

```js
grunt.initConfig({
  git: {
    branch: {
      options: {
        simple: {
          onComplete: function(err, stdout, callback) {
            if (err) {
              grunt.fail.fatal(err.message, err.code);
            } else {
              grunt.config.set('cli output', stdout);
              callback();
            }
          });
        }
      }
    }
  }
});
```

#### cmd

An alternative sub-command to call on the cli. This is useful when you want to create multiple targets that call the same command with different options/parameters. If this value is present, it will be used instead of the grunt target as the first argument to the executable.

```js
grunt.initConfig({
  // Using git as a real example
  git: {
    pushOrigin: {
      options: {
        simple: {
          cmd: 'push',
          args: ['origin', 'master']
        }
      }
    },
    pushHeroku: {
      options: {
        simple: {
          cmd: 'push',
          args: 'heroku master'
        }
      }
    }
  }
});
```

Running `grunt git:pushOrigin` will run `git push origin master` and running `grunt git:pushHeroku` will run `git push heroku master`.

#### args

Additional, non-flag arguments to pass to the executable. These can be passed as an array (as in `git:pushOrigin` above) or as a single string with arguments separated by a space (as in `git:pushHeroku` above).

#### rawArgs

`rawArgs` is a catch all for any arguments to git that can't be handled (for whatever reason) with the options above (e.g. the path arguments in some git commands: `git checkout master -- config/production.json`). Anything in `rawArgs` will be concatenated to the end of all the normal args.

```js
grunt.initConfig({
  git: {
    checkout: {
      options: {
        simple: {
          args: ['master'],
          rawArgs: '-- config/production.json'
        }
      }
    }
  }
});
```

#### debug

Similar to `--dry-run` in many executables. This will log the command that will be spawned in a child process without actually spawning it. Additionally, if you have an onComplete handler, a fake stderr and stdout will be passed to this handler, simulating the real task. If you want to use specific stderr/stdout messages, `debug` can also be an object with `stderr` and `stdout` properties that will be passed to the onComplete handler.

```js
grunt.initConfig({
  git: {
    branch: {
      options: {
        simple: {
          // Invoked with default fake stderr/stdout
          onComplete: function(err, stdout, callback) {
            console.log(arguments);
          },
          debug: true
        }
      }
    },
    status: {
      options: {
        simple: {
          // Invoked with 'foo' and 'bar'
          onComplete: function(err, stdout, callback) {
            console.log(arguments);
          },
          debug: {
            stderr: 'foo',
            stdout: 'bar'
          }
        }
      }
    }
  }
});
```

Additionally, you can pass the `--debug` option to grunt itself to enable the above behavior in an ad hoc manner.

### Dynamic values

Sometimes you just don't know what values you want to supply to for an option until you're ready to use it (for instance, `--message` in a commit task). That makes it hard to put into a task. `simple-cli` supports dynamical values (via interpolation) which can be supplied in any of three ways:

#### via command line options to grunt (e.g. grunt.option)

Supply the value when you call the task itself.

```js
grunt.initConfig({
  git: {
    push: {
      options: {
        simple: {
          // You can also do this as a string, but note that simple-cli splits
          // string args on space, so you wouldn't be able to put space INSIDE
          // the interpolation. You'd have to say args: '{{remote}} master'
          args: ['{{ remote }}', 'master']
        }
      }
    }
  }
});
```

If the above was invoked with `grunt git:push --remote origin` the final command would be `git push origin master`.

#### via grunt.config

This is primarily useful if you want the result of another task to determine the value of an argument. For instance, maybe in another task you say `grunt.config.set('remote', 'heroku')`, then the task above would run `git push heroku master`.

#### via prompt

If `simple-cli` can't find an interpolation value via `grunt.option` or `grunt.config`, it will prompt you for one on the terminal. Thus you could do something like:

```js
grunt.initConfig({
  git: {
    commit: {
      options: {
        message: '{{ message }}'
      }
    }
  }
});
```

and automate commits, while still supplying an accurate commit message.

### Shortcut configurations

For very simple tasks, you can define the task body as an array or string, rather than as an object, as all the above examples have been.

```js
grunt.initConfig({
  git: {
    // will invoke "git push origin master"
    origin: ['push', 'origin', 'master'],

    // will invoke "git pull upstream master"
    upstream: 'pull upstream master'
  }
});
