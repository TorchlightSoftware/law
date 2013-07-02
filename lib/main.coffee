module.exports = s =

  # Convenience method: load from file system and wrap in middleware
  # returns {serviceName: serviceDef}
  create: (location, jargon=[], policy=[]) ->
    defs = s.load location
    services = s.process defs, jargon
    final = s.applyPolicy services, policy

    return final

  # loads services from the file system
  # accepts (serviceLocation)
  # returns {serviceName: serviceDef}
  load: require './getServices'

  # processes service definitions into functions
  # accepts (services, jargon)
  # returns {serviceName: service}
  process: require './wrapServicesInMiddleware'

  # wraps services with access/lookup policy
  # accepts (services, policy)
  # returns {serviceName: wrappedService}
  applyPolicy: require './applyPolicy'

  # looks up and requires dependencies according to
  # the resolver file.
  # accepts (services, resolver)
  # returns {serviceName: wrappedService}
  applyDependencies: require './applyDependencies'

  # prints out the stack of filters applied to each service
  # accepts (services)
  # returns {serviceName: filterStack}
  print: require './printFilters'

