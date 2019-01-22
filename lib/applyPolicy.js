const {startsWith} = require('./util')
const generateFilter = require('./generateFilter')
const {InvalidServiceNameError, NoFilterArrayError} = require('./errors')

const getPolicy = function(services, policy) {
  if (policy == null) {
    policy = {}
  }
  if (!policy.rules) {
    policy.rules = []
  }

  // we'll apply a prefix if we have one
  const applyPrefix = policy.filterPrefix
    ? name => `${policy.filterPrefix}/${name}`
    : name => name

  // check to see that services used in policy are valid
  const validateServices = serviceNames => {
    const result = []
    for (let name of serviceNames) {
      const context = {serviceName: name}
      if (!services[name]) {
        throw new InvalidServiceNameError(context)
      } else {
        result.push(undefined)
      }
    }
    return result
  }

  // filter stack by service name
  const policyMap = {}
  for (let name in services) {
    policyMap[name] = []
  }

  // apply each rule to matching services
  for (let rule of policy.rules) {
    var service
    const context = {rule}
    if (rule.filters == null) {
      throw new NoFilterArrayError(context)
    }
    const filters = rule.filters.map(applyPrefix)
    validateServices(filters)

    if (rule.only != null) {
      validateServices(rule.only)
      for (service of rule.only) {
        policyMap[service].push(...(filters || []))
      }
    } else if (rule.except != null) {
      validateServices(rule.except)

      for (service in services) {
        // don't apply it to the exceptions, to any other filters, or to things not matching applyTo
        if (rule.except.includes(service)) continue
        if (policy.filterPrefix && startsWith(service, policy.filterPrefix))
          continue
        if (policy.applyTo && !service.match(policy.applyTo)) continue

        policyMap[service].push(...(filters || []))
      }
    }
  }

  return policyMap
}

const applyPolicy = function(services, policy) {
  // get our mapping, same as if we had printed it out
  const policyMap = getPolicy(services, policy)

  // return the original services with the new filters prepended
  for (let name in services) {
    const def = services[name]
    const filters = policyMap[name].map(filterName =>
      generateFilter(filterName, services[filterName])
    )

    services[name].prepend(filters)
  }

  return services
}

module.exports = applyPolicy
