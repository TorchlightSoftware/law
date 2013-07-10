# monkey patch the service definitions to insert dependencies
# this has to happen after all services have been loaded, in order
# to satisfy inter-service dependencies
module.exports = (services, resolvers) ->

  # NOTE: serviceName, serviceDef, and dependencies are prepared,
  # and captured later in a closure
  for serviceName, serviceDef of services
    dependencies = {} # dependencies root

    # resolve dependencies for all services and store them in a root object
    for dependencyType, dependencyNames of serviceDef.dependencies

      unless resolvers[dependencyType]?
        throw new Error "No resolution for dependencyType '#{dependencyType}'."

      # initialize sub-object for this dependencyType
      dependencies[dependencyType] = {}

      # populate it with resolved service references
      for dependencyName in dependencyNames

        resolved = resolvers[dependencyType] dependencyName

        unless resolved?
          throw new Error "No resolution for dependency '#{dependencyName}' of type '#{dependencyType}'."

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
        f args, done, serviceDef.dependencies

  # services have been modified internally
  return services
