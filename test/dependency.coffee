should = require 'should'
{join} = require 'path'

# lib stuff
{load, process, applyPolicy, print, create, print} = require '../lib/main'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'


describe 'dependency', ->
  beforeEach (done) ->
    @services = create serviceLocation, jargon, policy
    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething
    done()
    
  it 'should fail without a dependency load function wired up', (done) ->
    @services.doSomething {@sessionId}, (err) =>
      should.exist err
      err.message.should.equal 'Could not load dependency'
      done()

  it 'should not fail when the dependency load function is specified', (done) ->
    # specify loader, then...
    @services.doSomething {@sessionId}, (err) =>
      should.not.exist err
      done()