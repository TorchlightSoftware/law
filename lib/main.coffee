module.exports = s =

  # Convenience method: load from file system and wrap in middleware
  # returns {serviceName: serviceDef}
  create: (location, language=[], policy=[]) ->
    defs = s.load location
    services = s.process defs, language
    final = s.applyPolicy services, policy

    return final

  # loads services from the file system
  # accepts (serviceLocation)
  # returns {serviceName: serviceDef}
  load: require './getServices'

  # processes service definitions into functions
  # accepts (services, language)
  # returns {serviceName: service}
  process: require './wrapServicesInMiddleware'

  # wraps services with access/lookup policy
  # accepts (services, policy)
  # returns {serviceName: wrappedService}
  applyPolicy: require './applyPolicy'

  # prints out the stack of filters applied to each service
  # accepts (services)
  # returns {serviceName: filterStack}
  print: require './printFilters'
