module.exports = s =

  # Convenience method: wrap services in complete middleware stack
  # accepts {serviceName: serviceDef}
  # returns {serviceName: serviceDef} (wrapped)
  create: (defs, jargon=[], policy=[], resolvers={}) ->
    services = s.process defs, jargon
    withPolicy = s.applyPolicy services, policy
    final = s.applyDependencies withPolicy, resolvers

    return final

  # loads services from the file system (assumed to be in separate files)
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
  # the resolvers data structure.
  # accepts (services, resolvers)
  # returns {serviceName: wrappedService}
  applyDependencies: require './applyDependencies'

  # prints out the stack of filters applied to each service
  # accepts (services)
  # returns {serviceName: filterStack}
  print: require './printFilters'

  # exposes the 'graph' submodule, which includes functions to
  # take a set of services and return information about the graphs
  # graphs induced by the various dependency types, especially
  # the 'services' dependencyType.
  graph: require './graph'

  # Export LawError base type for extensions to depend upon.
  LawError: require('./errors').LawError