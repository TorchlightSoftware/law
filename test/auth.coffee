should = require 'should'
{join} = require 'path'

# lib stuff
{load, process, applyPolicy, print, create, print} = require '../lib/main'

# sample stuff
argTypes = require '../sample/app/domain/auth/argumentTypes'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'

describe "getServices", ->
  it 'should load a set of services', (done) ->
    serviceDefs = load serviceLocation

    (typeof serviceDefs).should.eql 'object'
    (typeof serviceDefs.login).should.eql 'function'
    (typeof serviceDefs.getRole).should.eql 'object'
    done()

describe "wrapServicesInMiddleware", ->
  it 'should generate usable services', (done) ->
    serviceDefs = load serviceLocation
    services = process serviceDefs, argTypes

    (typeof services.login).should.eql 'function'
    (typeof services.getRole).should.eql 'function'
    done()

describe "attachFilters", ->
  it 'should apply policy to services', (done) ->
    serviceDefs = load serviceLocation
    services = process serviceDefs, argTypes
    filteredServices = applyPolicy services, policy

    (typeof services.login).should.eql 'function'
    (typeof services.getRole).should.eql 'function'
    done()

describe "full stack", ->
  beforeEach (done) ->
    @services = create serviceLocation, argTypes, policy
    done()

  it 'should allow login to continue unhindered', (done) ->
    @services.login {}, (err, result) ->
      should.not.exist err
      should.exist result
      result.sessionId.should.eql 'foo'
      done()

  it 'should prevent dashboard from being accessed', (done) ->
    @services.dashboard {}, (err, result) ->
      should.exist err
      err.should.eql "filters/isLoggedIn requires 'sessionId' to be defined."
      done()

  describe 'getRole', ->
    it 'should require sessionId', (done) ->
      @services.getRole {}, (err, result) ->
        should.exist err
        err.should.eql "getRole requires 'sessionId' to be defined."
        done()

    it 'should validate sessionId', (done) ->
      @services.getRole {sessionId: 'foo'}, (err, result) ->
        should.exist err
        err.should.eql "getRole requires 'sessionId' to be a valid SessionId."
        done()

    it 'should pass valid arguments', (done) ->
      @services.getRole {sessionId: 'ab23ab23ab23ab23'}, (err, result) ->
        should.not.exist err
        should.exist result?.role, 'expected result.role'
        result.role.should.eql 'Supreme Commander'
        done()

  describe 'printFilters', ->
    it 'should work', (done) ->
      printout = print @services
      console.log printout
      done()
