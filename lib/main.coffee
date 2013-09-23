module.exports = law =

  # Convenience method: wrap services in complete middleware stack
  # accepts {serviceName: serviceDef}
  # returns {serviceName: serviceDef} (wrapped)
  create: ({services, jargon, policy, resolvers}) ->
    services = law.applyMiddleware(services, jargon)
    services = law.applyPolicy(services, policy)
    services = law.applyDependencies(services, resolvers)
    return services

  # loads services from the file system (assumed to be in separate files)
  # accepts (serviceLocation)
  # returns {serviceName: serviceDef}
  load: require './load'

  # processes service definitions into functions
  # accepts (services, jargon)
  # returns {serviceName: service}
  applyMiddleware: require './applyMiddleware'

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
  printFilters: require './printFilters'

  # exposes the 'graph' submodule, which includes functions to
  # take a set of services and return information about the graphs
  # graphs induced by the various dependency types, especially
  # the 'services' dependencyType.
  graph: require './graph'

  # Export 'errors' module for extensions to depend upon.
  errors: require './errors'
