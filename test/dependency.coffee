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
        return @services[serviceName]

    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething

    done()

  it 'should not fail on a service with no dependencies', (done) ->
    @services = applyDependencies @services, @resolver
    @services.helpDoSomething {@sessionId}, (err, {result}) =>
      should.not.exist err
      should.exist result
      result.should.equal 'it worked'
      done()

  it 'should not fail when the dependency load function is specified', (done) ->
    @services = applyDependencies @services, @resolver
    should.exist @services.doSomething.dependencies
    should.exist @services.doSomething.dependencies.services

    @services.doSomething {@sessionId}, (err, {result}) =>
      should.not.exist err
      should.exist result
      result.should.equal 'it worked'
      done()

  it "should accept the resolvers data structure in 'create'", (done) ->
    @services = create serviceLocation, jargon, policy, @resolver
    @services.doSomething {@sessionId}, (err) ->
      should.not.exist err
      done()

  it 'should allow usage of a parameterized resolvers file', (done) ->
    @services = create serviceLocation, jargon, policy
    makeResolvers = require '../sample/app/domain/auth/resolvers'
    resolvers = makeResolvers @services
    @services = applyDependencies @services, resolvers
    @services.doSomething {@sessionId}, (err) ->
      should.not.exist err
      done()