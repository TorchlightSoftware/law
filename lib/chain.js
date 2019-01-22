const {getType, isPromise} = require('./util')
const {
  InvalidArgumentsObjectError,
  ServiceReturnTypeError,
} = require('./errors')

// execute a stack of services (similar to async.waterfall)
module.exports = function(
  context, serviceName, input, stack, cb
) {
  // defaults
  if (!serviceName) serviceName = 'Service'
  if (!input) input = {}

  // if no callback was provided, then return a promise
  let p
  if (!cb) {
    p = new Promise((resolve, reject) => {
      cb = (err, results) => {
        err ? reject(err) : resolve(results)
      }
    })
  }

  // validations
  if (getType(input) !== 'Object') {
    context = {serviceName, input}
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

    let hasBeenCalled = false
    const service = stack[index]
    const processResults = function(err, results) {

      // only call it once
      if (hasBeenCalled) return
      hasBeenCalled = true

      // Law guarantees to always output an object
      if (!results) results = {}
      if (getType(results) !== 'Object') {
        context = {
          serviceName: service.serviceName || serviceName,
          results,
        }
        return cb(new ServiceReturnTypeError(context))
      }

      if (err) return cb(err, results)

      // iterate the counter to run the next service
      callNext(index + 1, results)
    }

    // run current service
    let returnVal
    if (getType(service) === 'AsyncFunction') {
      returnVal = service.call(context, args, service.dependencies)
    }
    else {
      returnVal = service.call(
        context, args, processResults, service.dependencies
      )
    }

    // support promises/async services
    if (isPromise(returnVal)) {
      returnVal
        .catch(processResults)
        .then(results => processResults(null, results))
    }
  }

  // begin execution
  callNext(0, input)

  // return a promise if no callback was provided
  return p
}
