should = require 'should'

{
  LawError
  FailedArgumentLookupError
  MissingArgumentError
  InvalidArgumentError
} = errors = require '../lib/errors'


describe 'LawError inheritance and defaults', ->
  for ErrName, Err of errors
    do (ErrName, Err) ->
      describe "Inheritance of #{ErrName}", ->

        beforeEach (done) ->
          @err = new Err()
          console.log {@err}
          should.exist @err
          done()

        it 'should be an instance of Error', (done) ->
          console.log 'typeof @err', typeof @err
          (@err instanceof Error).should.be.true
          done()

        it 'should be an instance of LawError', (done) ->
          (@err instanceof LawError).should.be.true
          done()

        it "should be an instance of its own class (#{ErrName})", (done) ->
          (@err instanceof Err).should.be.true
          done()

        it 'should inherit Error, tea-error properties', (done) ->
          should.exist @err.toJSON
          should.exist @err.message
          should.exist @err.stack
          done()

      describe "An instance of #{ErrName} without any passed arguments", ->
        beforeEach (done) ->
          @err = new Err()
          should.exist @err
          done()

        it 'should have a reasonable default message', (done) ->
          expectedMessage = "Unspecified #{@err.name}"
          @err.message.should.equal expectedMessage
          done()

describe 'FailedArgumentLookupError', ->

  describe 'an instance with passed arguments', ->
    beforeEach (done) ->
      @message = 'Could not look up required argument `username`'
      @properties =
        serviceName: 'doSomething'
        args:
          sessionId: 'deadbeef'
          timestamp: Date.now()
      @err = new FailedArgumentLookupError @message, @properties
      done()

    it 'should have a correct, descriptive message', (done) ->
      should.exist @err.message
      @err.message.should.equal @message
      done()

    it 'should have the properties we gave it', (done) ->
      @err.should.include @properties
      done()

describe 'MissingArgumentError', ->
  beforeEach (done) ->
    @message = 'Missing required argument `username`'
    @properties =
      serviceName: 'doSomething'
      args:
        sessionId: 'deadbeef'
        timestamp: Date.now()
    @err = new MissingArgumentError @message, @properties
    done()

  it 'should have a correct, descriptive message', (done) ->
    @err.message.should.equal @message
    done()

describe 'InvalidArgumentError', ->
  beforeEach (done) ->
    @message = 'Invalid argument `sessionId`'
    @properties =
      serviceName: 'doSomething'
      args:
        sessionId: 'malformed'
        timestamp: Date.now()
    @err = new InvalidArgumentError @message, @properties
    done()

  it 'should have a correct, descriptive message', (done) ->
    @err.message.should.equal @message
    done()