applyDependencies = (services, resolver) ->
  wrappedServices = {}

  for serviceName, serviceDef of services
    dependencies = {}

    # we will create keys for any declared dependency types
    # and have them map to resolved dependencies
    for dependencyType of serviceDef.dependencies
      # initialize sub-object for this dependencyType
      dependencies[dependencyType] = {}

      # populate it with resolved service references
      for dependencyName in serviceDef.dependencies[dependencyType]

        unless dependencyType of resolver
          throw new Error "No resolution for dependencyType '#{dependencyType}'."

        resolved = resolver[dependencyType] dependencyName

        unless resolved?
          throw new Error "No resolution for dependency '#{dependencyName}' of type '#{dependencyType}'."

        dependencies[dependencyType][dependencyName] = resolved

    makeWrapper = (serviceName, serviceDef, dependencies) ->
      # start with a copy of the service up until now
      wrapper = serviceDef

      # add a handle to our newly-resolved dependencies
      wrapper.dependencies = dependencies

      # grab a reference to the raw service as-defined
      f = wrapper.callStack[wrapper.callStack.length-1]

      # pseudo-right curry to inject the `dependencies` reference and
      # ensure the signature is chain-friendly throughout `callStack`
      wrapper.callStack[wrapper.callStack.length-1] = (args, done) ->
        f args, done, wrapper.dependencies

      return wrapper

    wrapper = makeWrapper serviceName, serviceDef, dependencies
    wrappedServices[serviceName] = wrapper

  return wrappedServices

module.exports = applyDependencies
