const should = require('should')
const logger = require('torch')
const {join} = require('path')

// lib stuff
const {
  load,
  applyMiddleware,
  applyPolicy,
  printFilters,
  create,
} = require('../lib/main')

// sample stuff
const jargon = require('../sample/app/domain/auth/jargon')
const serviceLocation = join(__dirname, '../sample/app/domain/auth/services')
const policy = require('../sample/app/domain/auth/policy')

describe('auth', function() {
  describe('getServices', () =>
    it('should load a set of services', function(done) {
      const serviceDefs = load(serviceLocation)

      ;(typeof serviceDefs).should.eql('object')
      ;(typeof serviceDefs.login).should.eql('function')
      ;(typeof serviceDefs.getRole).should.eql('object')
      done()
    }))

  describe('applyMiddleware', function() {
    it('should not error with empty jargon', function(done) {
      const serviceDefs = load(serviceLocation)
      const services = applyMiddleware(serviceDefs) // no jargon

      ;(typeof services.login).should.eql('function')
      ;(typeof services.getRole).should.eql('function')
      done()
    })

    it('should generate usable services', function(done) {
      const serviceDefs = load(serviceLocation)
      const services = applyMiddleware(serviceDefs, jargon)

      ;(typeof services.login).should.eql('function')
      ;(typeof services.getRole).should.eql('function')
      done()
    })
  })

  describe('applyPolicy', function() {
    it('should apply policy to services', function(done) {
      const serviceDefs = load(serviceLocation)
      const services = applyMiddleware(serviceDefs, jargon)
      const filteredServices = applyPolicy(services, policy)

      ;(typeof services.login).should.eql('function')
      ;(typeof services.getRole).should.eql('function')
      done()
    })

    it('should apply empty policy', function(done) {
      const serviceDefs = load(serviceLocation)
      const services = applyMiddleware(serviceDefs, jargon)
      const filteredServices = applyPolicy(services) // no policy

      ;(typeof services.login).should.eql('function')
      ;(typeof services.getRole).should.eql('function')
      done()
    })
  })

  describe('full stack', function() {
    beforeEach(function(done) {
      const services = load(serviceLocation)
      this.services = create({services, jargon, policy})
      done()
    })

    it('should maintain binding context', function(done) {
      this.services.relayContext.call({prop: 2}, {}, function(err, context) {
        //logger.blue {context}
        should.exist(context)
        should.exist(context.prop)
        context.prop.should.eql(2)
        done()
      })
    })

    it('should allow login to continue unhindered', function(done) {
      this.services.login({}, function(err, result) {
        should.not.exist(err)
        should.exist(result)
        result.sessionId.should.eql('foo')
        done()
      })
    })

    it('should be callable without args', function(done) {
      this.services.login(function(err, result) {
        should.not.exist(err)
        should.exist(result)
        result.sessionId.should.eql('foo')
        done()
      })
    })

    it('should prevent dashboard from being accessed', function(done) {
      this.services.dashboard({}, function(err, result) {
        should.exist(err, 'expected error')
        should.exist(err.message, 'expected error message')
        err.message.should.eql(
          "'filters/isLoggedIn' requires 'sessionId' to be defined."
        )
        for (let field of ['reason', 'fieldName', 'serviceName']) {
          Object.keys(err).should.containEql(field)
        }
        done()
      })
    })

    it('should require results to be an object', function(done) {
      this.services.invalidReturn({}, function(err, result) {
        should.exist(err, 'expected error')
        should.exist(err.message, 'expected error message')
        err.message.should.eql("'invalidReturn' must return an object.")
        done()
      })
    })

    describe('getRole', function() {
      it('should require sessionId', function(done) {
        this.services.getRole({}, function(err, result) {
          should.exist(err, 'expected error')
          should.exist(err.message, 'expected error message')
          err.message.should.eql(
            "'getRole' requires 'sessionId' to be defined."
          )
          err.should.containEql({
            reason: 'requiredField',
            fieldName: 'sessionId',
            serviceName: 'getRole',
            args: {},
          })
          done()
        })
      })

      it('should validate stringyness', function(done) {
        this.services.sendEmail({email: [], subject: ''}, function(
          err,
          result
        ) {
          should.exist(err, 'expected error')
          should.exist(err.message, 'expected error message')
          err.message.should.eql('email is not a string.')
          err.should.containEql({
            fieldName: 'email',
            value: [],
            serviceName: 'sendEmail',
            args: {email: [], subject: ''},
            reason: 'invalidValue',
            requiredType: 'String',
            message: 'email is not a string.',
          })

          done()
        })
      })

      it('should validate sessionId', function(done) {
        this.services.getRole({sessionId: 'foo'}, function(err, result) {
          should.exist(err, 'expected error')
          should.exist(err.message, 'expected error message')
          err.message.should.eql(
            "'getRole' requires 'sessionId' to be a valid 'SessionId'."
          )
          for (let field of [
            'reason',
            'fieldName',
            'serviceName',
            'requiredType',
          ]) {
            Object.keys(err).should.containEql(field)
          }
          done()
        })
      })

      it('should pass valid arguments', function(done) {
        this.services.getRole({sessionId: 'ab23ab23ab23ab23'}, function(
          err,
          result
        ) {
          should.not.exist(err)
          should.exist(result, 'expected result')
          should.exist(result.role, 'expected result.role')
          result.role.should.eql('Supreme Commander')
          done()
        })
      })

      it('should lookup accountId', function(done) {
        this.services.getRole({sessionId: 'ab23ab23ab23ab23'}, function(
          err,
          result
        ) {
          should.not.exist(err)
          should.exist(result, 'expected result')
          should.exist(result.accountId, 'expected result.accountId')
          done()
        })
      })
    })

    describe('printFilters', () =>
      it('should work', function(done) {
        const printout = printFilters(this.services)
        console.log(printout)
        done()
      }))
  })
})
