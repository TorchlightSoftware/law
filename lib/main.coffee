module.exports = s =

  # Convenience method: load from file system and wrap in middleware
  # returns {serviceName: serviceDef}
  auto: (dirname) ->
    s.wrap s.load dirname

  # loads services from the file system
  # returns {serviceName: serviceDef}
  load: require './getServices'

  # processes service definitions into functions
  # returns {serviceName: service}
  process: require './wrapServicesInMiddleware'

  # wraps services with access/lookup policy
  # returns {serviceName: wrappedService}
  stack: (services, policy) ->
