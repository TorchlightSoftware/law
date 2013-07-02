should = require 'should'

{join} = require 'path'

# lib stuff
{load, process, applyPolicy, applyDependencies, print, create, print} = require '../lib/main'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'

describe 'applyDependencies', ->
  beforeEach (done) ->
    # replicate use of non-dependency create helper
    defs = load serviceLocation
    @services = process defs, jargon
    @services = applyPolicy @services, policy
    
    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething

    @resolver =
      services: (serviceName) =>
        @services[serviceName]

    done()

  it 'should create a `dependency` field in the exposed service', (done) ->
    @services = applyDependencies @services, @resolver
    # a service with declared dependencies
    should.exist @services.doSomething.dependencies

    # a service without declared dependencies
    should.exist @services.helpDoSomething.dependencies

    done()

  it 'should have an empty object when there are no dependencies', (done) ->
    @services = applyDependencies @services, @resolver
    
    # we should have a `dependencies` object
    should.exist @services.helpDoSomething.dependencies
    # but it should be empty (no keys)
    should.not.exist @services.helpDoSomething.dependencies.keys
    
    done()
    
  it 'should inject expose declared dependencies when there', (done) ->
    @services = applyDependencies @services, @resolver
    should.exist @services.doSomething.dependencies
    should.exist @services.doSomething.dependencies.services
    should.exist @services.doSomething.dependencies.services.helpDoSomething
    
    done()