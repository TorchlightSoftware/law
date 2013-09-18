should = require 'should'

{
  LawError
  FailedArgumentLookupError
  MissingArgumentError
  InvalidArgumentError
} = require '../lib/errors'


describe 'errors', ->
  describe 'LawError', ->
    beforeEach (done) ->
      @err = new LawError()
      done()

    it 'should be an instance of Error', (done) ->
      (@err instanceof Error).should.be.true
      done()

    it 'should be an instance of LawError', (done) ->
      (@err instanceof LawError).should.be.true
      done()

  describe 'FailedArgumentLookupError', ->
    describe 'an instance without any passed arguments', ->
      beforeEach (done) ->
        @err = new FailedArgumentLookupError()
        done()

      describe 'inheriting from LawError', ->
        it 'should be an instance of Error', (done) ->
          (@err instanceof Error).should.be.true
          done()

        it 'should be an instance of LawError', (done) ->
          (@err instanceof LawError).should.be.true
          done()

        it 'should be an instance of FailedArgumentLookupError', (done) ->
          (@err instanceof FailedArgumentLookupError).should.be.true
          done()

        it 'should inherit Error, tea-error properties', (done) ->
          should.exist @err.toJSON
          should.exist @err.message
          should.exist @err.stack
          done()

      it 'should have a reasonable default message', (done) ->
        expectedMessage = 'Unspecified LawError/FailedArgumentLookup'
        @err.message.should.equal expectedMessage
        done()

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

    it 'should be an instance of MissingArgumentError', (done) ->
      (@err instanceof MissingArgumentError).should.be.true
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

    it 'should be an instance of InvalidArgumentError', (done) ->
      (@err instanceof InvalidArgumentError).should.be.true
      done()

    it 'should have a correct, descriptive message', (done) ->
      @err.message.should.equal @message
      done()