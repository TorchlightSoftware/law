let errors;
const should = require('should');

const {
  LawError,
  FailedArgumentLookupError,
  InvalidArgumentError,
  InvalidArgumentsObjectError,
  InvalidServiceNameError,
  MissingArgumentError,
  NoFilterArrayError,
  ServiceDefinitionNoCallableError,
  ServiceDefinitionTypeError,
  ServiceReturnTypeError,
  UnresolvableDependencyError,
  UnresolvableDependencyTypeError
} = (errors = require('../lib/errors'));


const defaultContext = {
  serviceName: 'doSomething',
  fieldName: 'sessionId',
  requiredType: 'SessionId',
  args: {
    sessionId: 'malformed',
    timestamp: Date.now()
  }
};


const testData = [
  {
    errorType: FailedArgumentLookupError,
    expected: {
      message: "Service 'doSomething' is not an object or a function."
    }
  },
  {
    errorType: InvalidArgumentError,
    expected: {
      message: "'doSomething' requires 'sessionId' to be a valid 'SessionId'."
    }
  },
  {
    errorType: InvalidArgumentsObjectError,
    expected: {
      message: "'doSomething' requires an arguments object as the first argument."
    }
  },
  {
    errorType: InvalidServiceNameError,
    expected: {
      message: "Error loading policy: 'doSomething' is not a valid service name."
    }
  },
  {
    errorType: MissingArgumentError,
    expected: {
      message: "'doSomething' requires 'sessionId' to be defined."
    }
  },
  {
    errorType: NoFilterArrayError,
    expected: {
      message: "Error loading policy: Validations must contain array of filters."
    }
  },
  {
    errorType: ServiceDefinitionNoCallableError,
    expected: {
      message: "Could not find function definition for service 'doSomething'."
    }
  },
  {
    errorType: ServiceDefinitionTypeError,
    expected: {
      message: "Service 'doSomething' is not an object or a function."
    }
  },
  {
    errorType: ServiceReturnTypeError,
    expected: {
      message: "'doSomething' must return an object."
    }
  },
  {
    errorType: UnresolvableDependencyError,
    context: {
      serviceName: 'doSomething',
      dependencyName: 'helpDoSomething',
      dependencyType: 'service'
    },
    expected: {
      message: "Loading 'doSomething': No resolution for dependency 'helpDoSomething' of type 'service'."
    }
  },
  {
    errorType: UnresolvableDependencyTypeError,
    context: {
      serviceName: 'doSomething',
      dependencyType: 'service'
    },
    expected: {
      message: "Loading 'doSomething': No resolution for dependencyType 'service'."
    }
  }
];


for (let datum of testData) {
  (function(datum) {
    const {errorType, context, expected, start} = datum;
    const description = `${errorType.name}`;

    describe(description, function() {
      beforeEach(function(done) {
        this.context = context || defaultContext;
        this.err = new errorType(this.context);
        should.exist(this.err, 'Error instance should exist');
        done();
      });

      it('should include its context and any other expected properties', function(done) {
        this.err.should.containEql(this.context);
        if (expected.properties) {
          this.err.should.containEql(expected.properties);
        }

        done();
      });

      it('should have a correct, descriptive message', function(done) {
        should.exist(this.err.message);
        this.err.message.should.equal(expected.message);
        done();
      });
    });
  })(datum);
}
