{merge} = require './util'
coreResolvers = require './coreResolvers'
{
  UnresolvableDependencyError
  UnresolvableDependencyTypeError
} = require './errors'

# extend the service calls to insert dependencies
# this has to happen after all services have been loaded, in order
# to satisfy inter-service dependencies
module.exports = (services, providedResolvers) ->
  resolvers = {}
  merge resolvers, coreResolvers(services)
  merge resolvers, providedResolvers

  # NOTE: serviceName, serviceDef, and dependencies are prepared,
  # and captured later in a closure
  for serviceName, serviceDef of services
    dependencies = {} # dependencies root

    # resolve dependencies for all services and store them in a root object
    for dependencyType, dependencyNames of serviceDef.dependencies

      unless resolvers[dependencyType]?
        context =
          serviceName: serviceName
          dependencyType: dependencyType
        throw (new UnresolvableDependencyTypeError context)

      # initialize sub-object for this dependencyType
      dependencies[dependencyType] = {}

      # populate it with resolved service references
      for dependencyName in dependencyNames

        resolved = resolvers[dependencyType] dependencyName

        unless resolved?
          context =
            serviceName: serviceName
            dependencyName: dependencyName
            dependencyType: dependencyType
          throw (new UnresolvableDependencyError context)

        dependencies[dependencyType][dependencyName] = resolved

    # capture dependencies in a closure
    do (serviceName, serviceDef, dependencies) ->

      # add a handle to our newly-resolved dependencies
      serviceDef.dependencies = dependencies
      baseServiceIndex = serviceDef.callStack.length-1

      # grab a reference to the raw service as-defined
      f = serviceDef.callStack[baseServiceIndex]

      # inject the dependencies into the base service,
      # while leaving the rest of the callStack untouched
      serviceDef.callStack[baseServiceIndex] = (args, done) ->
        f.call @, args, done, serviceDef.dependencies

  # services have been modified internally
  return services
