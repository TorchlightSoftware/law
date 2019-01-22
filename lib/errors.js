const error = require('tea-error')

// Create a constructor for better errors
const LawError = error('LawError')

// Lots of copy-paste code, obvious shared structure in the class
// definitions below. Can this be factored out in a CS-idiomatic way?

class FailedArgumentLookupError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `Service '${serviceName}' is not an object or a function.`

    super(message, context, start)
  }
}
FailedArgumentLookupError.prototype.name = 'LawError/FailedArgumentLookup'

class InvalidArgumentError extends LawError {
  constructor(context, start) {
    const {serviceName, fieldName, requiredType} = context
    const message =
      context.message ||
      `'${serviceName}' requires '${fieldName}' to be a valid '${requiredType}'.`

    super(message, context, start)
  }
}
InvalidArgumentError.prototype.name = 'LawError/InvalidArgumentError'

class InvalidArgumentsObjectError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `'${serviceName}' requires an arguments object as the first argument.`

    super(message, context, start)
  }
}
InvalidArgumentsObjectError.prototype.name =
  'LawError/InvalidArgumentsObjectError'

class InvalidServiceNameError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `Error loading policy: '${serviceName}' is not a valid service name.`

    super(message, context, start)
  }
}
InvalidServiceNameError.prototype.name = 'LawError/InvalidServiceNameError'

class MissingArgumentError extends LawError {
  constructor(context, start) {
    const {serviceName, fieldName} = context
    const message = `'${serviceName}' requires '${fieldName}' to be defined.`

    super(message, context, start)
  }
}
MissingArgumentError.prototype.name = 'LawError/MissingArgumentError'

class NoFilterArrayError extends LawError {
  constructor(context, start) {
    const message =
      'Error loading policy: Validations must contain array of filters.'

    super(message, context, start)
  }
}
NoFilterArrayError.prototype.name = 'LawError/NoFilterArrayError'

class ServiceDefinitionNoCallableError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `Could not find function definition for service '${serviceName}'.`

    super(message, context, start)
  }
}
ServiceDefinitionNoCallableError.prototype.name =
  'LawError/ServiceDefinitionNoCallableError'

class ServiceDefinitionTypeError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `Service '${serviceName}' is not an object or a function.`

    super(message, context, start)
  }
}
ServiceDefinitionTypeError.prototype.name =
  'LawError/ServiceDefinitionTypeError'

class ServiceReturnTypeError extends LawError {
  constructor(context, start) {
    const {serviceName} = context
    const message = `'${serviceName}' must return an object.`

    super(message, context, start)
  }
}
ServiceReturnTypeError.prototype.name = 'LawError/ServiceReturnTypeError'

class UnresolvableDependencyError extends LawError {
  constructor(context, start) {
    const {serviceName, dependencyName, dependencyType} = context
    const message = `Loading '${serviceName}': No resolution for dependency '${dependencyName}' of type '${dependencyType}'.`

    super(message, context, start)
  }
}
UnresolvableDependencyError.prototype.name =
  'LawError/UnresolvableDependencyError'

class UnresolvableDependencyTypeError extends LawError {
  constructor(context, start) {
    const {serviceName, dependencyType} = context
    const message = `Loading '${serviceName}': No resolution for dependencyType '${dependencyType}'.`

    super(message, context, start)
  }
}
UnresolvableDependencyTypeError.prototype.name =
  'LawError/UnresolvableDependencyTypeError'

module.exports = {
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
  UnresolvableDependencyTypeError,
}
