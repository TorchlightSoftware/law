should = require 'should'

{join} = require 'path'

# lib stuff
{load, applyMiddleware, applyPolicy, applyDependencies, create, printFilters} = require '../lib/main'
{
  UnresolvableDependencyError
  UnresolvableDependencyTypeError
} = require '../lib/errors'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'

# these will blow up if we attempt to applyDependencies
badServices =
  beUnsatisfied:
    dependencies:
      services: ['nonexistentService']
    required: []
    service: (args, next, {services}) ->
      next()

  haveBadDependencyType:
    dependencies:
      badDependencyType: ['anotherNonexistentService']
    required: []
    service: (args, next, {}) ->
      next()

orthogonalDependers =
  doThis:
    dependencies:
      services: ['helpDoThis']
    required: []
    service: (args, next, {services}) ->
      should.exist services.helpDoThis
      should.not.exist services.helpDoThat
      services.helpDoThis args, next
  helpDoThis:
    required: []
    service: (args, next, {}) ->
      next()
  doThat:
    dependencies:
      services: ['helpDoThat']
    required: []
    service: (args, next, {services}) ->
      should.not.exist services.helpDoThis
      should.exist services.helpDoThat
      services.helpDoThat args, next
  helpDoThat:
    required: []
    service: (args, next, {}) ->
      next()

describe 'applyDependencies', ->
  beforeEach (done) ->
    # replicate use of non-dependency create helper
    defs = load serviceLocation
    @services = applyMiddleware defs, jargon
    @services = applyPolicy @services, policy

    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething

    @resolver =
      services: (serviceName) =>
        @services[serviceName]

    done()

  it "should not error with empty resolvers", (done) ->
    @services = applyDependencies @services, @resolver
    done()

  it "should create a 'dependency' field in the exposed service", (done) ->
    @services = applyDependencies @services, @resolver
    # a service with declared dependencies
    should.exist @services.doSomething.dependencies

    # a service without declared dependencies
    should.exist @services.helpDoSomething.dependencies

    done()

  it 'should have an empty object when there are no dependencies', (done) ->
    @services = applyDependencies @services, @resolver

    # we should have a 'dependencies' object
    should.exist @services.helpDoSomething.dependencies
    # but it should be empty (no keys)
    should.not.exist @services.helpDoSomething.dependencies.keys

    done()

  it 'should expose declared dependencies when there', (done) ->
    @services = applyDependencies @services, @resolver
    should.exist @services.doSomething.dependencies
    should.exist @services.doSomething.dependencies.services
    should.exist @services.doSomething.dependencies.services.helpDoSomething

    done()

  it 'should fail with an error when a dependency is not met', (done) ->
    # declared at top of file
    @services.beUnsatisfied = badServices.beUnsatisfied
    @services = applyMiddleware @services, jargon
    @services = applyPolicy @services, policy

    try
      @services = applyDependencies @services, @resolver
    catch err
      should.exist err
      (err instanceof UnresolvableDependencyError).should.be.true
      err.message.should.equal "Loading 'beUnsatisfied': No resolution for dependency 'nonexistentService' of type 'services'."
      done()

  it 'should fail with an error when a dependencyType is not resolvable', (done) ->
    # declared at top of file
    @services.haveBadDependencyType = badServices.haveBadDependencyType
    @services = applyMiddleware @services, jargon
    @services = applyPolicy @services, policy

    try
      @services = applyDependencies @services, @resolver
    catch err
      should.exist err
      (err instanceof UnresolvableDependencyTypeError).should.be.true
      err.message.should.equal "Loading 'haveBadDependencyType': No resolution for dependencyType 'badDependencyType'."
      done()

  it 'should only inject dependencies into their dependent services', (done) ->
    for k, v of orthogonalDependers
      @services[k] = v
    @services = applyMiddleware @services, jargon
    @services = applyPolicy @services, policy
    @services = applyDependencies @services, @resolver

    for k, v of orthogonalDependers
      should.exist @services[k]

    @services.doThis {@sessionId}, (err) =>
      should.not.exist err
      @services.doThat {@sessionId}, (err) =>
        should.not.exist err
        done()

  it 'should work when the service has no metadata', (done) ->
    @services.bare = (args, done) -> done()
    @services = applyMiddleware @services, jargon
    @services = applyPolicy @services, policy
    @services = applyDependencies @services, @resolver
    @services.bare {@sessionId}, (err) ->
      should.not.exist err
      done()
