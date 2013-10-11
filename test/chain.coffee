should = require 'should'

describe 'chain', ->
  it 'should chain a set of services', (done) ->
    chain = require '../lib/chain'

    fooService = (args, done) ->
      done()

    barService = (args, done) ->
      done()

    chain 'testService', {}, [fooService, barService], (err, args) ->
      should.not.exist err
      should.exist args
      args.should.be.a 'object'
      done()

  it 'should return proper signature in case of an error', (done) ->
    chain = require '../lib/chain'

    fooService = (args, done) ->
      done new Error 'yo'

    barService = (args, done) ->
      done()

    chain 'testService', {}, [fooService, barService], (err, args) ->
      should.exist err, 'expected error'
      err.should.eql new Error 'yo'
      should.exist args, 'expected args'
      args.should.be.a 'object'
      done()

  it 'should retain meta info in case of an error', (done) ->
    chain = require '../lib/chain'

    fooService = (args, done) ->
      error = new Error 'yo'
      done error, {reason: 'just cus'}

    chain 'testService', {}, [fooService], (err, args) ->
      should.exist err, 'expected error'
      err.should.eql new Error 'yo'
      should.exist args, 'expected args'
      args.reason.should.eql 'just cus'
      done()

  it 'should error on invalid input', (done) ->
    chain = require '../lib/chain'

    chain 'testService', 'foo', [], (err, args) ->
      should.exist err?.message, 'expected error'
      err.message.should.eql "'testService' requires an arguments object as the first argument."
      done()
