# execute a stack of services (similar to async.waterfall)
module.exports = (serviceName, input, stack, cb) ->

  # defaults
  serviceName ||= 'Service'
  input ||= {}
  cb ||= ->

  # validations
  unless (typeof input) is 'object'
    return cb (new Error "#{serviceName} requires an arguments object as the first argument."), {input: input}
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
      unless (typeof results) is 'object'
        return cb (new Error "#{stack[index].serviceName or serviceName} must return an object."), {results: results}
      return cb err, {} if err
      callNext index + 1, results

  # begin execution
  callNext 0, input
