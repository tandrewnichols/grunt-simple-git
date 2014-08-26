cp = require 'child_process'

describe 'acceptance', ->
  Given (done) ->
    @grunt = cp.spawn 'grunt', ['git']
    @grunt.stdout.on 'data', (data) => @output += data.toString()
    @grunt.on 'close', ->
      done()
  Then ->
    console.log @output
    expect(@output).to.contain('Travis integration') and
    expect(@output).to.contain('# On branch master') and
    expect(@output).to.contain('Deleted branch foo') and
    expect(@output).to.contain('master') and
    expect(@output).to.contain('Geez')
