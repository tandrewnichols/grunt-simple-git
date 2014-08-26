EventEmitter = require('events').EventEmitter

describe 'git', ->
  Given -> @grunt = spyObj 'registerMultiTask'
  Given -> @context =
    async: sinon.stub()
    options: sinon.stub()
    data: {}
  Given -> @cb = ->
  Given -> @context.async.returns @cb
  Given -> @context.options.returns {}
  Given -> @cp =
    spawn: sinon.stub()
  Given -> @subject = sandbox '../tasks/git',
    child_process: @cp

  When -> @subject(@grunt)
  And -> expect(@grunt.registerMultiTask).to.have.been.calledWith 'git', 'A simple API for using git via grunt', sinon.match.func

  describe 'command with git options', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['commit', '--message', 'A commit message'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'commit'
    Given -> @context.options.returns
      message: 'A commit message'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with a boolean flag', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['status', '--short'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'status'
    Given -> @context.options.returns
      short: true
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with short flags', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['status', '-ac', '-b', 'foo', '-d', 'bar'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'status'
    Given -> @context.options.returns
      a: true
      b: 'foo'
      c: true
      d: 'bar'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with extra options', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['commit', '--message', 'A commit message'], { stdio: 'foo', cwd: 'bar' }).returns @emitter
    Given -> @context.target = 'commit'
    Given -> @context.options.returns
      message: 'A commit message'
    Given -> @context.data =
      stdio: 'foo'
      cwd: 'bar'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with sub-commands', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['remote', 'show', 'origin'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'remote'
    Given -> @context.data =
      cmd: 'remote show origin'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with sub-commands with "git" at the front', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['remote', 'show', 'origin'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'remote'
    Given -> @context.data =
      cmd: 'git remote show origin'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'command with a different name', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['remote', 'show', 'origin'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'banana'
    Given -> @context.data =
      cmd: 'remote show origin'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'dasherizes commands and options', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['rev-parse', '--use-dashes'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'revParse'
    Given -> @context.options.returns
      useDashes: true
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'allows raw args as string', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['log', '--format=%s'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'log'
    Given -> @context.data =
      rawArgs: '--format=%s'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'allows raw args as array', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['log', '---blah^foo hi'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'log'
    Given -> @context.data =
      rawArgs: ['---blah^foo hi']
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'options have equal sign', ->
    Given -> @emitter = new EventEmitter()
    Given -> @cp.spawn.withArgs('git', ['log', '--author=nichols'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.target = 'log'
    Given -> @context.options.returns
      'author=': 'nichols'
    When ->
      @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called
