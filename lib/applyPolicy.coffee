{startsWith} = require './util'
generateFilter = require './generateFilter'
{InvalidServiceNameError, NoFilterArrayError} = require './errors'


getPolicy = (services, policy={}) ->
  policy.rules or= []

  # we'll apply a prefix if we have one
  applyPrefix =
    if policy.filterPrefix
      (name) -> "#{policy.filterPrefix}/#{name}"
    else
      (name) -> name

  # check to see that services used in policy are valid
  validateServices = (serviceNames) ->
    for name in serviceNames
      context =
        serviceName: name
      throw (new InvalidServiceNameError context) unless services[name]

  # filter stack by service name
  policyMap = {}
  for name of services
    policyMap[name] = []

  # apply each rule to matching services
  for rule in policy.rules
    context = {rule}
    throw new NoFilterArrayError context unless rule.filters?
    filters = rule.filters.map applyPrefix
    validateServices filters

    if rule.only?
      validateServices rule.only
      for service in rule.only
        policyMap[service].push filters...

    else if rule.except?
      validateServices rule.except

      for service of services

        # don't apply it to the exceptions, to any other filters, or to things not matching applyTo
        continue if service in rule.except
        continue if policy.filterPrefix and startsWith service, policy.filterPrefix
        continue if policy.applyTo and not service.match policy.applyTo

        policyMap[service].push filters...

  return policyMap

applyPolicy = (services, policy) ->

  # get our mapping, same as if we had printed it out
  policyMap = getPolicy services, policy

  # return the original services with the new filters prepended
  for name, def of services
    filters = for filterName in policyMap[name]
      generateFilter filterName, services[filterName]

    services[name].prepend filters

  return services

module.exports = applyPolicy
