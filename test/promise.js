const should = require('should')
const {join} = require('path')

// lib stuff
const {load, applyDependencies, create, printFilters} = require('../lib/main')

// sample stuff
const jargon = require('../sample/app/domain/auth/jargon')
const serviceLocation = join(__dirname, '../sample/app/domain/auth/services')
const policy = require('../sample/app/domain/auth/policy')

describe('promise', function() {
  it('should chain a set of services', function(done) {
    const chain = require('../lib/chain')

    const fooService = async (args) => null

    const barService = async (args) => null

    chain(null, 'testService', {}, [fooService, barService], (err, args) => {
      should.not.exist(err)
      should.exist(args)
      args.should.eql({})
      done()
    })
  })

  it('should return proper signature in case of an error', function(done) {
    const chain = require('../lib/chain')
    const fooService = async (args) => {throw new Error('yo')}
    const barService = async (args) => null

    chain(null, 'testService', {}, [fooService, barService], (err, args) => {
      should.exist(err, 'expected error')
      err.should.eql(new Error('yo'))
      should.exist(args, 'expected args')
      args.should.eql({})
      done()
    })
  })

  it('should pass context', function(done) {
    const chain = require('../lib/chain')

    const contextService = async function(args) {
      return this
    }

    chain({x: 1}, 'contextService', {}, [contextService], (err, context) => {
      should.exist(context, 'expected context')
      context.x.should.eql(1)
      done()
    })
  })

  it('should run async filter and service', function(done) {
    const services = create({
      services: load(serviceLocation),
      jargon,
      policy
    })

    services.doSomethingAsync({
      sessionId: 'ab23ab23ab23ab23',
      arbitrary: true
    }, (err, {a, b}) => {
      should.not.exist(err)
      should.exist(a)
      should.exist(b)
      a.should.equal(1)
      b.should.equal(1)
      done()
    })

  })

  it('should return a promise', function(done) {
    const services = create({
      services: load(serviceLocation),
      jargon,
      policy
    })

    services.doSomethingAsync({
      sessionId: 'ab23ab23ab23ab23',
      arbitrary: true
    }).then(({a, b}) => {
      should.exist(a)
      should.exist(b)
      a.should.equal(1)
      b.should.equal(1)
      done()
    })
    .catch(done)

  })

})
