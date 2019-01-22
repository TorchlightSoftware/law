const should = require('should')

const {join} = require('path')

// lib stuff
const {
  load,
  applyMiddleware,
  applyPolicy,
  applyDependencies,
  create,
  printFilters,
} = require('../lib/main')

const {
  UnresolvableDependencyError,
  UnresolvableDependencyTypeError,
} = require('../lib/errors')

// sample stuff
const jargon = require('../sample/app/domain/auth/jargon')
const serviceLocation = join(__dirname, '../sample/app/domain/auth/services')
const policy = require('../sample/app/domain/auth/policy')

// these will blow up if we attempt to applyDependencies
const badServices = {
  beUnsatisfied: {
    dependencies: {
      services: ['nonexistentService'],
    },
    required: [],
    service(args, next, {services}) {
      next()
    },
  },

  haveBadDependencyType: {
    dependencies: {
      badDependencyType: ['anotherNonexistentService'],
    },
    required: [],
    service(args, next) {
      next()
    },
  },
}

const orthogonalDependers = {
  doThis: {
    dependencies: {
      services: ['helpDoThis'],
    },
    required: [],
    service(args, next, {services}) {
      should.exist(services.helpDoThis)
      should.not.exist(services.helpDoThat)
      services.helpDoThis(args, next)
    },
  },
  helpDoThis: {
    required: [],
    service(args, next, ...rest) {
      next()
    },
  },
  doThat: {
    dependencies: {
      services: ['helpDoThat'],
    },
    required: [],
    service(args, next, {services}) {
      should.not.exist(services.helpDoThis)
      should.exist(services.helpDoThat)
      return services.helpDoThat(args, next)
    },
  },
  helpDoThat: {
    required: [],
    service(args, next) {
      next()
    },
  },
}

describe('applyDependencies', function() {
  beforeEach(function(done) {
    // replicate use of non-dependency create helper
    const defs = load(serviceLocation)
    this.services = applyMiddleware(defs, jargon)
    this.services = applyPolicy(this.services, policy)

    this.sessionId = 'ab23ab23ab23ab23'
    should.exist(this.services.doSomething)
    should.exist(this.services.helpDoSomething)

    this.resolver = {
      services: serviceName => {
        return this.services[serviceName]
      },
    }

    done()
  })

  it('should not error with empty resolvers', function(done) {
    this.services = applyDependencies(this.services, this.resolver)
    done()
  })

  it("should create a 'dependency' field in the exposed service", function(done) {
    this.services = applyDependencies(this.services, this.resolver)
    // a service with declared dependencies
    should.exist(this.services.doSomething.dependencies)

    // a service without declared dependencies
    should.exist(this.services.helpDoSomething.dependencies)

    done()
  })

  it('should have an empty object when there are no dependencies', function(done) {
    this.services = applyDependencies(this.services, this.resolver)

    // we should have a 'dependencies' object
    should.exist(this.services.helpDoSomething.dependencies)
    // but it should be empty (no keys)
    should.not.exist(this.services.helpDoSomething.dependencies.keys)

    done()
  })

  it('should expose declared dependencies when there', function(done) {
    this.services = applyDependencies(this.services, this.resolver)
    should.exist(this.services.doSomething.dependencies)
    should.exist(this.services.doSomething.dependencies.services)
    should.exist(
      this.services.doSomething.dependencies.services.helpDoSomething
    )

    done()
  })

  it('should fail with an error when a dependency is not met', function(done) {
    // declared at top of file
    this.services.beUnsatisfied = badServices.beUnsatisfied
    this.services = applyMiddleware(this.services, jargon)
    this.services = applyPolicy(this.services, policy)

    try {
      this.services = applyDependencies(this.services, this.resolver)
    } catch (err) {
      should.exist(err)
      ;(err instanceof UnresolvableDependencyError).should.be.true
      err.message.should.equal(
        "Loading 'beUnsatisfied': No resolution for dependency 'nonexistentService' of type 'services'."
      )
      done()
    }
  })

  it('should fail with an error when a dependencyType is not resolvable', function(done) {
    // declared at top of file
    this.services.haveBadDependencyType = badServices.haveBadDependencyType
    this.services = applyMiddleware(this.services, jargon)
    this.services = applyPolicy(this.services, policy)

    try {
      this.services = applyDependencies(this.services, this.resolver)
    } catch (err) {
      should.exist(err)
      ;(err instanceof UnresolvableDependencyTypeError).should.be.true
      err.message.should.equal(
        "Loading 'haveBadDependencyType': No resolution for dependencyType 'badDependencyType'."
      )
      done()
    }
  })

  it('should only inject dependencies into their dependent services', function(done) {
    for (let k in orthogonalDependers) {
      this.services[k] = orthogonalDependers[k]
    }
    this.services = applyMiddleware(this.services, jargon)
    this.services = applyPolicy(this.services, policy)
    this.services = applyDependencies(this.services, this.resolver)

    for (k in orthogonalDependers) {
      should.exist(this.services[k])
    }

    this.services.doThis({sessionId: this.sessionId}, err => {
      should.not.exist(err)
      this.services.doThat({sessionId: this.sessionId}, err => {
        should.not.exist(err)
        done()
      })
    })
  })

  it('should work when the service has no metadata', function(done) {
    this.services.bare = (args, done) => done()
    this.services = applyMiddleware(this.services, jargon)
    this.services = applyPolicy(this.services, policy)
    this.services = applyDependencies(this.services, this.resolver)
    this.services.bare({sessionId: this.sessionId}, function(err) {
      should.not.exist(err)
      done()
    })
  })
})
