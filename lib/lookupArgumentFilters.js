const {getType} = require('./util')
const createServiceFilters = require('./createServiceFilters')
const {ServiceDefinitionTypeError} = require('./errors')

module.exports = function(serviceName, serviceDef, jargon) {
  const generateDefaultValidations = createServiceFilters(jargon)

  switch (getType(serviceDef)) {
    case 'Function':
      return []

    case 'Object':
      var validations = []
      var {required, optional} = serviceDef

      if (required) {
        validations = validations.concat(
          generateDefaultValidations(serviceName, required, true)
        )
      }

      if (optional) {
        validations = validations.concat(
          generateDefaultValidations(serviceName, optional, false)
        )
      }

      return validations

    default:
      throw new ServiceDefinitionTypeError({serviceName})
  }
}
