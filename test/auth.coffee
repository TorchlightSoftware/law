should = require 'should'
logger = require 'torch'
{join} = require 'path'

# lib stuff
{load, applyMiddleware, applyPolicy, printFilters, create} = require '../lib/main'

# sample stuff
jargon = require '../sample/app/domain/auth/jargon'
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
policy = require '../sample/app/domain/auth/policy'

describe "auth", ->

  describe "getServices", ->
    it 'should load a set of services', (done) ->
      serviceDefs = load serviceLocation

      (typeof serviceDefs).should.eql 'object'
      (typeof serviceDefs.login).should.eql 'function'
      (typeof serviceDefs.getRole).should.eql 'object'
      done()

  describe "applyMiddleware", ->
    it 'should not error with empty jargon', (done) ->
      serviceDefs = load serviceLocation
      services = applyMiddleware serviceDefs # no jargon

      (typeof services.login).should.eql 'function'
      (typeof services.getRole).should.eql 'function'
      done()

    it 'should generate usable services', (done) ->
      serviceDefs = load serviceLocation
      services = applyMiddleware serviceDefs, jargon

      (typeof services.login).should.eql 'function'
      (typeof services.getRole).should.eql 'function'
      done()

  describe "applyPolicy", ->
    it 'should apply policy to services', (done) ->
      serviceDefs = load serviceLocation
      services = applyMiddleware serviceDefs, jargon
      filteredServices = applyPolicy services, policy

      (typeof services.login).should.eql 'function'
      (typeof services.getRole).should.eql 'function'
      done()

    it 'should apply empty policy', (done) ->
      serviceDefs = load serviceLocation
      services = applyMiddleware serviceDefs, jargon
      filteredServices = applyPolicy services # no policy

      (typeof services.login).should.eql 'function'
      (typeof services.getRole).should.eql 'function'
      done()

  describe "full stack", ->
    beforeEach (done) ->
      services = load serviceLocation
      @services = create {services, jargon, policy}
      done()

    it 'should maintain binding context', (done) ->
      @services.relayContext.call {prop: 2}, {}, (err, context) ->
        #logger.blue {context}
        should.exist context?.prop
        context.prop.should.eql 2
        done()

    it 'should allow login to continue unhindered', (done) ->
      @services.login {}, (err, result) ->
        should.not.exist err
        should.exist result
        result.sessionId.should.eql 'foo'
        done()

    it 'should be callable without args', (done) ->
      @services.login (err, result) ->
        should.not.exist err
        should.exist result
        result.sessionId.should.eql 'foo'
        done()

    it 'should prevent dashboard from being accessed', (done) ->
      @services.dashboard {}, (err, result) ->
        should.exist err?.message, 'expected error'
        err.message.should.eql "'filters/isLoggedIn' requires 'sessionId' to be defined."
        for field in ['reason', 'fieldName', 'serviceName']
          Object.keys(err).should.include field
        done()

    it 'should require results to be an object', (done) ->
      @services.invalidReturn {}, (err, result) ->
        should.exist err?.message, 'expected error'
        err.message.should.eql "'invalidReturn' must return an object."
        done()

    describe 'getRole', ->
      it 'should require sessionId', (done) ->
        @services.getRole {}, (err, result) ->
          should.exist err?.message, 'expected error'
          err.message.should.eql "'getRole' requires 'sessionId' to be defined."
          err.should.include
            reason: 'requiredField'
            fieldName: 'sessionId'
            serviceName: 'getRole'
            args: {}
          done()

      it 'should validate stringyness', (done) ->
        @services.sendEmail {email: [], subject: ''}, (err, result) ->
          should.exist err?.message, 'expected error'
          err.message.should.eql 'email is not a string.'
          err.should.include
            fieldName: 'email'
            value: []
            serviceName: 'sendEmail'
            args: {email: [], subject: ''}
            reason: 'invalidValue'
            requiredType: 'String'
            message: 'email is not a string.'

          done()

      it 'should validate sessionId', (done) ->
        @services.getRole {sessionId: 'foo'}, (err, result) ->
          should.exist err?.message, 'expected error'
          err.message.should.eql "'getRole' requires 'sessionId' to be a valid 'SessionId'."
          for field in ['reason', 'fieldName', 'serviceName', 'requiredType']
            Object.keys(err).should.include field
          done()

      it 'should pass valid arguments', (done) ->
        @services.getRole {sessionId: 'ab23ab23ab23ab23'}, (err, result) ->
          should.not.exist err
          should.exist result?.role, 'expected result.role'
          result.role.should.eql 'Supreme Commander'
          done()

      it 'should lookup accountId', (done) ->
        @services.getRole {sessionId: 'ab23ab23ab23ab23'}, (err, result) ->
          should.not.exist err
          should.exist result?.accountId, 'expected result.accountId'
          done()

    describe 'printFilters', ->
      it 'should work', (done) ->
        printout = printFilters @services
        console.log printout
        done()
