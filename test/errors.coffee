should = require 'should'

{
  LawError
  FailedArgumentLookupError
  InvalidArgumentError
  InvalidArgumentsObjectError
  InvalidServiceNameError
  MissingArgumentError
  NoFilterArrayError
  ServiceDefinitionNoCallableError
  ServiceDefinitionTypeError
  ServiceReturnTypeError
  UnresolvableDependencyError
  UnresolvableDependencyTypeError
} = errors = require '../lib/errors'


defaultContext =
  serviceName: 'doSomething'
  fieldName: 'sessionId'
  requiredType: 'SessionId'
  args:
    sessionId: 'malformed'
    timestamp: Date.now()


testData = [
  # {
  #   errorType: FailedArgumentLookupError
  #   expected:
  #     message: "Service 'doSomething' is not an object or a function."
  # }
  {
    errorType: InvalidArgumentError
    expected:
      message: "'doSomething' requires 'sessionId' to be a valid 'SessionId'."
  }
  {
    errorType: InvalidArgumentsObjectError
    expected:
      message: "'doSomething' requires an arguments object as the first argument."
  }
  {
    errorType: InvalidServiceNameError
    expected:
      message: "Error loading policy: 'doSomething' is not a valid service name."
  }
  {
    errorType: MissingArgumentError
    expected:
      message: "'doSomething' requires 'sessionId' to be defined."
  }
  {
    errorType: NoFilterArrayError
    expected:
      message: "Error loading policy: Validations must contain array of filters."
  }
  {
    errorType: ServiceDefinitionNoCallableError
    expected:
      message: "Could not find function definition for service 'doSomething'."
  }
  {
    errorType: ServiceDefinitionTypeError
    expected:
      message: "Service 'doSomething' is not an object or a function."
  }
  {
    errorType: ServiceReturnTypeError
    expected:
      message: "'doSomething' must return an object."
  }
  {
    errorType: UnresolvableDependencyError
    context:
      serviceName: 'doSomething'
      dependencyName: 'helpDoSomething'
      dependencyType: 'service'
    expected:
      message: "Loading 'doSomething': No resolution for dependency 'helpDoSomething' of type 'service'."
  }
  {
    errorType: UnresolvableDependencyTypeError
    context:
      serviceName: 'doSomething'
      dependencyType: 'service'
    expected:
      message: "Loading 'doSomething': No resolution for dependencyType 'service'."
  }
]


for datum in testData
  do (datum) ->
    {errorType, context, expected, start} = datum
    description = "#{errorType.name}"

    describe description, ->
      beforeEach (done) ->
        @context = context or defaultContext
        @err = new errorType @context
        should.exist @err, 'Error instance should exist'
        done()

      it 'should include its context and any other expected properties', (done) ->
        @err.should.include @context
        if expected.properties
          @err.should.include expected.properties

        done()

      it 'should have a correct, descriptive message', (done) ->
        should.exist @err.message
        @err.message.should.equal expected.message
        done()
