error = require 'tea-error'

# Create a constructor for better errors
LawError = error 'LawError'

# Lots of copy-paste code, obvious shared structure in the class
# definitions below. Can this be factored out in a CS-idiomatic way?

class FailedArgumentLookupError extends LawError
  name: 'LawError/FailedArgumentLookup'

  constructor: (context, start) ->
    {serviceName} = context
    message = "Service '#{serviceName}' is not an object or a function."

    super message, context, start


class InvalidArgumentError extends LawError
  name: 'LawError/InvalidArgument'

  constructor: (context, start) ->
    {serviceName, fieldName, requiredType} = context
    message = context.message or "'#{serviceName}' requires '#{fieldName}' to be a valid '#{requiredType}'."

    super message, context, start


class InvalidArgumentsObjectError extends LawError
  name: 'LawError/InvalidArgumentsObject'

  constructor: (context, start) ->
    {serviceName} = context
    message = "'#{serviceName}' requires an arguments object as the first argument."

    super message, context, start


class InvalidServiceNameError extends LawError
  name: 'LawError/InvalidServiceName'

  constructor: (context, start) ->
    {serviceName} = context
    message = "Error loading policy: '#{serviceName}' is not a valid service name."

    super message, context, start


class MissingArgumentError extends LawError
  name: 'LawError/MissingArgument'

  constructor: (context, start) ->
    {serviceName, fieldName} = context
    message = "'#{serviceName}' requires '#{fieldName}' to be defined."

    super message, context, start


class NoFilterArrayError extends LawError
  name: 'LawError/NoFilterArray'

  constructor: (context, start) ->
    message = "Error loading policy: Validations must contain array of filters."

    super message, context, start


class ServiceDefinitionNoCallableError extends LawError
  name: 'LawError/ServiceDefinitionNoCallable'

  constructor: (context, start) ->
    {serviceName} = context
    message = "Could not find function definition for service '#{serviceName}'."

    super message, context, start





class ServiceDefinitionTypeError extends LawError
  name: 'LawError/ServiceDefinitionType'

  constructor: (context, start) ->
    {serviceName} = context
    message = "Service '#{serviceName}' is not an object or a function."

    super message, context, start


class ServiceReturnTypeError extends LawError
  name: 'LawError/ServiceReturnType'

  constructor: (context, start) ->
    {serviceName} = context
    message = "'#{serviceName}' must return an object."

    super message, context, start


class UnresolvableDependencyError extends LawError
  name: 'LawError/UnresolvableDependency'

  constructor: (context, start) ->
    {serviceName, dependencyName, dependencyType} = context
    message = "Loading '#{serviceName}': No resolution for dependency '#{dependencyName}' of type '#{dependencyType}'."

    super message, context, start


class UnresolvableDependencyTypeError extends LawError
  name: 'LawError/UnresolvableDependencyType'

  constructor: (context, start) ->
    {serviceName, dependencyType} = context
    message = "Loading '#{serviceName}': No resolution for dependencyType '#{dependencyType}'."

    super message, context, start


module.exports = {
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
}
