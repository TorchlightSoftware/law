{addTo, compact, flatten} = require './util'
generateFilter = require './generateFilter'

# generate validations that will be added to the filter stack
generateValidations = (serviceName, name, types, required) ->
  stack = []

  # get lookups
  addTo stack, types.map (t) ->
    if t.lookup
      generateFilter "#{name}.lookup", (args, next) ->

        # perform lookup if arg is not present
        if not args[name]?
          t.lookup args, (err, result) ->
            args[name] = result
            next err, args
        else
          next()

  # check existance
  addTo stack, generateFilter "#{name}.exists", (args, next) ->

    # only check if it's not present but required
    if not args[name]? and required
      return next new Error "#{serviceName} requires '#{name}' to be defined."
    else
      return next()

  # get type validations
  addTo stack, types.map (t) ->
    if t.validation
      generateFilter "#{name}.isValid(#{t.typeName})", (args, next) ->

        checkResult = (passed) ->
          return next new Error "#{serviceName} requires '#{name}' to be a valid #{t.typeName}." unless passed
          next()

        # continue if field isn't present
        return next() unless args[name]

        # run type validation
        t.validation args[name], checkResult, args

  # remove any lookups/validations that weren't defined
  return compact stack

module.exports =
  (argumentTypes) ->

    # get a list of filter functions for a set of required/optional fields
    generateDefaultValidations: (serviceName, fieldNames, required) ->
      validations =
        for name in fieldNames
          types = (t for t in argumentTypes when t.defaultArgs and name in t.defaultArgs)
          vals = generateValidations serviceName, name, types, required
          vals

      return flatten validations

    # get a list of filter functions for a set of detailed param specs
    generateValidationsFromParams: (serviceName, paramSpecs) ->
      validations =
        for param in paramSpecs

          # throw if required fields not present in spec
          for field in ['name', 'required', 'validation']
            throw new Error "#{serviceName}.paramSpecs must contain '#{field}'." unless field in param.keys()

          # find types and wrap in validations
          if (typeof param.validation) is 'function'
            param.validation

          else
            param.validation = [param.validation] unless Array.isArray param.validation
            types = (t for t in argumentTypes when t.typeName in param.validation)
            generateValidations serviceName, param.name, types, param.required

      return flatten validations
