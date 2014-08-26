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

  describe 'command with git options only', ->
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
