const {getType, addTo, compact, flatten, merge} = require('./util')
const generateFilter = require('./generateFilter')
const {MissingArgumentError, InvalidArgumentError} = require('./errors')

// generate validations that will be added to the filter stack
const generateValidations = function(serviceName, name, types, required) {
  const stack = []

  // get lookups
  addTo(
    stack,
    types.map(function(t) {
      if (t.lookup) {
        return generateFilter(`${name}.lookup`, function(args, next) {
          // perform lookup if arg is not present
          if (args[name] == null) {
            t.lookup(args, function(err, result) {
              if (err) {
                args = {
                  reason: 'lookupFailed',
                  fieldName: name,
                  serviceName,
                  args,
                }
              } else {
                args[name] = result
              }

              next(err, args)
            })
          } else {
            next()
          }
        })
      }
    })
  )

  // check existence
  addTo(
    stack,
    generateFilter(`${name}.exists`, function(args, next) {
      // only check if it's not present but required
      if (args[name] == null && required) {
        const context = {
          reason: 'requiredField',
          fieldName: name,
          serviceName,
          args,
        }

        next(new MissingArgumentError(context))
      } else {
        next()
      }
    })
  )

  // get type validations
  addTo(
    stack,
    types.map(function(t) {
      if (t.validation) {
        return generateFilter(`${name}.isValid(${t.typeName})`, function(
          args,
          next
        ) {
          // continue if field isn't present
          if (!args[name]) {
            next()
          }

          const context = {
            fieldName: name,
            value: args[name],
            serviceName,
            args,
          }

          const assert = function(passed, extraContext) {
            if (!passed) {
              merge(context, {reason: 'invalidValue', requiredType: t.typeName})
              merge(context, extraContext)

              next(new InvalidArgumentError(context))
            } else {
              next()
            }
          }

          // run type validation
          t.validation(context, assert)
        })
      }
    })
  )

  // remove any lookups/validations that weren't defined
  return compact(stack)
}

module.exports = jargon =>
  // get a list of filter functions for a set of required/optional fields
  function(serviceName, fieldNames, required) {
    const validations = []
    for (var name of fieldNames) {
      const types = jargon.filter(
        word => word.defaultArgs && word.defaultArgs.includes(name)
      )
      const vals = generateValidations(serviceName, name, types, required)
      validations.push(vals)
    }
    return flatten(validations)
  }
