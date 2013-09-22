should = require 'should'
{join} = require 'path'

# lib stuff
{load, applyDependencies, create} = require '../lib/main'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'

describe 'dependency', ->
  beforeEach (done) ->
    services = load serviceLocation
    @services = create {services, jargon, policy}

    @sessionId = 'ab23ab23ab23ab23'
    should.exist @services.doSomething
    should.exist @services.helpDoSomething

    done()

  it 'should not fail on a service with no dependencies', (done) ->
    @services.helpDoSomething {@sessionId}, (err, {result}) =>
      should.not.exist err
      should.exist result
      result.should.equal 'it worked'
      done()

  it 'should reference a service', (done) ->
    @services.doSomething {@sessionId}, (err, {result}) =>
      should.not.exist err
      should.exist result
      result.should.equal 'it worked'
      done()

  it 'should reference a lib', (done) ->
    @services.useLib {@sessionId}, (err, {compiled}) ->
      should.not.exist err
      should.exist compiled

      compiled = compiled.replace /\n/g, ''
      compiled.should.eql 'console.log("hello");'
      done()

  #it "should accept the resolvers data structure in 'create'", (done) ->
    #@services.doSomething {@sessionId}, (err) ->
      #should.not.exist err
      #done()

  #it 'should allow usage of a parameterized resolvers file', (done) ->
    #@services.doSomething {@sessionId}, (err) ->
      #should.not.exist err
      #done()
