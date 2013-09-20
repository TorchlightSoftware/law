{getType} = require './util'
{ServiceDefinitionSignatureError, ServiceReturnTypeError} = require './errors'


# execute a stack of services (similar to async.waterfall)
module.exports = (serviceName, input, stack, cb, dependencies) ->

  # defaults
  serviceName ||= 'Service'
  input ||= {}
  cb ||= ->

  # validations
  unless getType(input) is 'Object'
    context =
      serviceName: serviceName
      input: input
    return cb (new ServiceDefinitionSignatureError context)
  unless Array.isArray(stack) and stack.length > 0
    return cb()

  # stack iterator
  callNext = (index, args) ->

    # exit condition
    unless index < stack.length
      return cb null, args

    # run next service
    stack[index] args, (err, results) ->
      results ||= {}
      unless getType(results) is 'Object'
        context =
          serviceName: stack[index].serviceName or serviceName
          results: results
        return cb (new ServiceReturnTypeError context)
        # return cb (new Error "#{stack[index].serviceName or serviceName} must return an object."), {results: results}
      return cb err, results if err
      callNext index + 1, results

  # begin execution
  callNext 0, input
