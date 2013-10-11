{getType} = require './util'
createServiceFilters = require './createServiceFilters'
{ServiceDefinitionTypeError} = require './errors'

module.exports = (serviceName, serviceDef, jargon) ->
  generateDefaultValidations = createServiceFilters jargon

  switch getType serviceDef

    when 'Function'
      return []

    when 'Object'
      validations = []
      {required, optional} = serviceDef

      if required
        validations = validations.concat generateDefaultValidations serviceName, required, true

      if optional
        validations = validations.concat generateDefaultValidations serviceName, optional, false

      return validations

    else
      throw (new ServiceDefinitionTypeError {serviceName})
