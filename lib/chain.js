const {getType} = require('./util')
const {
  InvalidArgumentsObjectError,
  ServiceReturnTypeError,
} = require('./errors')

// execute a stack of services (similar to async.waterfall)
module.exports = function(
  context,
  serviceName,
  input,
  stack,
  cb,
  dependencies
) {
  // defaults
  if (!serviceName) {
    serviceName = 'Service'
  }
  if (!input) {
    input = {}
  }
  if (!cb) {
    cb = function() {}
  }

  // validations
  if (getType(input) !== 'Object') {
    context = {
      serviceName,
      input,
    }
    return cb(new InvalidArgumentsObjectError(context))
  }
  if (!Array.isArray(stack) || !(stack.length > 0)) {
    cb()
  }

  // stack iterator
  var callNext = function(index, args) {
    // exit condition
    if (!(index < stack.length)) {
      return cb(null, args)
    }

    // run next service
    stack[index].call(context, args, function(err, results) {
      if (!results) {
        results = {}
      }
      if (getType(results) !== 'Object') {
        context = {
          serviceName: stack[index].serviceName || serviceName,
          results,
        }
        return cb(new ServiceReturnTypeError(context))
      }

      if (err) return cb(err, results)
      callNext(index + 1, results)
    })
  }

  // begin execution
  callNext(0, input)
}
