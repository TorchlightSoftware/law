const should = require('should')
const chain = require('../lib/chain')

describe('chain', function() {
  it('should chain a set of services', function(done) {

    const fooService = (args, done) => done()

    const barService = (args, done) => done()

    chain(null, 'testService', {}, [fooService, barService], (err, args) => {
      should.not.exist(err)
      should.exist(args)
      args.should.eql({})
      done()
    })
  })

  it('should return proper signature in case of an error', function(done) {
    const fooService = (args, done) => done(new Error('yo'))
    const barService = (args, done) => done()

    chain(null, 'testService', {}, [fooService, barService], (err, args) => {
      should.exist(err, 'expected error')
      err.should.eql(new Error('yo'))
      should.exist(args, 'expected args')
      args.should.eql({})
      done()
    })
  })

  it('should retain meta info in case of an error', function(done) {
    const fooService = function(args, done) {
      const error = new Error('yo')
      done(error, {reason: 'just cus'})
    }

    chain(null, 'testService', {}, [fooService], (err, args) => {
      should.exist(err, 'expected error')
      err.should.eql(new Error('yo'))
      should.exist(args, 'expected args')
      args.reason.should.eql('just cus')
      done()
    })
  })

  it('should pass context', function(done) {
    const contextService = function(args, done) {
      done(null, this)
    }

    chain({x: 1}, 'contextService', {}, [contextService], (err, context) => {
      should.exist(context, 'expected context')
      context.x.should.eql(1)
      done()
    })
  })

  it('should error on invalid input', function(done) {
    chain(null, 'testService', 'foo', [], (err, args) => {
      should.exist(err, 'expected error')
      should.exist(err.message, 'expected error')
      err.message.should.eql(
        "'testService' requires an arguments object as the first argument."
      )
      done()
    })
  })

  it('should throw invalid callback', function(done) {
    const fooService = (args, done) => done()
    const barService = (args, done) => done()

    chain(null, 'testService', {}, [fooService, barService], 'foo')
    done()
  })
})
