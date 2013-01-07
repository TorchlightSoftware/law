module.exports = util =

  # works like concat, but modifies array
  addTo: (arr, addition) ->
    if Array.isArray addition
      arr.push addition...
    else
      arr.push addition

  # promote elements out of nested arrays
  flatten: (arr) ->
    return arr unless Array.isArray arr

    flattened = []
    for a in arr
      util.addTo flattened, a

    return flattened

  # remove null/undefined elements from array
  compact: (arr) ->
    return arr unless Array.isArray arr
    (a for a in arr when a?)

  # does target string start with search?
  startsWith: (target, search) ->
    target.indexOf(search) is 0

  # merge source hash into target
  merge: (target, source) ->
    return target unless (typeof target) is 'object' and (typeof source) is 'object'
    for name, value in source
      target[name] = value
    return target

  # execute a stack of services (similar to async.waterfall)
  chain: (serviceName, input, stack, cb) ->
    cb ||= ->
    unless (typeof input) is 'object'
      return new Error "#{serviceName} requires an arguments object as the first argument."
    unless Array.isArray(stack) and stack.length > 0
      return cb()

    callNext = (index, args) ->

      # exit condition
      unless index < stack.length
        unless (typeof args) is 'object'
          return cb new Error "#{serviceName} must return an object."
        return cb null, args

      # run next service
      stack[index] args, (err, results) ->
        return cb err if err
        callNext index + 1, results

    # begin execution
    callNext 0, input
