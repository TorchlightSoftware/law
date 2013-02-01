{getType, addTo, compact, flatten, merge} = require './util'
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

            if err
              args =
                reason: 'lookupFailed'
                fieldName: name
                serviceName: serviceName
                args: args
            else
              args[name] = result

            next err, args
        else
          next()

  # check existance
  addTo stack, generateFilter "#{name}.exists", (args, next) ->

    # only check if it's not present but required
    if not args[name]? and required
      context =
        reason: 'requiredField'
        fieldName: name
        serviceName: serviceName
        args: args

      error = new Error "#{serviceName} requires '#{name}' to be defined."
      return next error, context

    else
      return next()

  # get type validations
  addTo stack, types.map (t) ->
    if t.validation
      generateFilter "#{name}.isValid(#{t.typeName})", (args, next) ->

        # continue if field isn't present
        return next() unless args[name]

        context =
          fieldName: name
          value: args[name]
          serviceName: serviceName
          args: args

        assert = (passed, extraContext) ->
          unless passed
            merge context, {reason: 'invalidValue', requiredType: t.typeName}
            merge context, extraContext

            error = new Error "#{serviceName} requires '#{name}' to be a valid #{t.typeName}."
            return next error, context

          else
            return next()

        # run type validation
        t.validation context, assert

  # remove any lookups/validations that weren't defined
  return compact stack

module.exports =
  (jargon) ->

    # get a list of filter functions for a set of required/optional fields
    generateDefaultValidations: (serviceName, fieldNames, required) ->
      validations =
        for name in fieldNames
          types = (word for word in jargon when word.defaultArgs and name in word.defaultArgs)
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
          if getType(param.validation) is 'Function'
            param.validation

          else
            param.validation = [param.validation] unless Array.isArray param.validation
            types = (word for word in jargon when word.typeName in param.validation)
            generateValidations serviceName, param.name, types, param.required

      return flatten validations
