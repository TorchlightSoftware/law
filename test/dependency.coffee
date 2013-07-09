should = require 'should'
{join} = require 'path'

# lib stuff
{load, process, applyPolicy, applyDependencies, print, create, print} = require '../lib/main'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'


describe 'dependency', ->
  beforeEach (done) ->
    @services = create serviceLocation, jargon, policy
    @resolver =
      services: (serviceName) =>
        console.log "resolving service: #{serviceName}"
        return @services[serviceName]
    
    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething
    
    done()

  it 'should not fail on a service with no dependencies', (done) ->
    @services = applyDependencies @services, @resolver
    @services.helpDoSomething {@sessionId}, (err) =>
      should.not.exist err
      done()
            
  it 'should fail without a dependency load function wired up', (done) ->
    # @services = applyDependencies @services, @resolver
    @services.doSomething {@sessionId}, (err) =>
      should.exist err
      err.message.should.equal 'Could not load dependency'
      done()

  it 'should not fail when the dependency load function is specified', (done) ->
    @services = applyDependencies @services, @resolver
    should.exist @services.doSomething.dependencies
    should.exist @services.doSomething.dependencies.services
    
    @services.doSomething {@sessionId}, ((err, {result}) =>
      should.not.exist err
      should.exist result
      result.should.equal 'it worked'
      done()
    ), @services.doSomething.dependencies