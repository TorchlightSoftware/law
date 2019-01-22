const {merge} = require('./util')
const coreResolvers = require('./coreResolvers')
const {
  UnresolvableDependencyError,
  UnresolvableDependencyTypeError,
} = require('./errors')

// extend the service calls to insert dependencies
// this has to happen after all services have been loaded, in order
// to satisfy inter-service dependencies
module.exports = function(services, providedResolvers) {
  const resolvers = {}
  merge(resolvers, coreResolvers(services))
  merge(resolvers, providedResolvers)

  // NOTE: serviceName, serviceDef, and dependencies are prepared,
  // and captured later in a closure
  for (let serviceName in services) {
    const serviceDef = services[serviceName]
    const dependencies = {} // dependencies root

    // resolve dependencies for all services and store them in a root object
    for (let dependencyType in serviceDef.dependencies) {
      var context
      const dependencyNames = serviceDef.dependencies[dependencyType]
      if (resolvers[dependencyType] == null) {
        context = {
          serviceName,
          dependencyType,
        }
        throw new UnresolvableDependencyTypeError(context)
      }

      // initialize sub-object for this dependencyType
      dependencies[dependencyType] = {}

      // populate it with resolved service references
      for (let dependencyName of dependencyNames) {
        const resolved = resolvers[dependencyType](dependencyName)

        if (resolved == null) {
          context = {
            serviceName,
            dependencyName,
            dependencyType,
          }
          throw new UnresolvableDependencyError(context)
        }

        dependencies[dependencyType][dependencyName] = resolved
      }
    }

    // capture dependencies in a closure
    ;(function(serviceName, serviceDef, dependencies) {
      // add a handle to our newly-resolved dependencies
      serviceDef.dependencies = dependencies
      const baseServiceIndex = serviceDef.callStack.length - 1

      // grab a reference to the raw service as-defined
      const f = serviceDef.callStack[baseServiceIndex]

      // inject the dependencies into the base service,
      // while leaving the rest of the callStack untouched
      serviceDef.callStack[baseServiceIndex] = function(args, done) {
        f.call(this, args, done, serviceDef.dependencies)
      }
    })(serviceName, serviceDef, dependencies)
  }

  // services have been modified internally
  return services
}
