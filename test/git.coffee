describe 'git', ->
  Given -> @grunt =
    registerMultiTask: sinon.stub()
  Given -> @context =
    async: sinon.stub()
  Given -> @cb = sinon.stub()
  Given -> @context.async.returns @cb
  Given -> @simpleCli =
    spawn: sinon.stub()
  Given -> @subject = sandbox '../tasks/git',
    'simple-cli': @simpleCli

  When -> @subject(@grunt)
  And -> expect(@grunt.registerMultiTask).to.have.been.calledWith 'git', 'A simple API for using git via grunt', sinon.match.func
  And -> @grunt.registerMultiTask.getCall(0).args[2].apply @context, []
  Then -> expect(@simpleCli.spawn).to.have.been.calledWith @grunt, @context, 'git', @cb
