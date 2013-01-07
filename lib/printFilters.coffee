module.exports = (services) ->
  output = {}
  for serviceName, serviceDef of services
    output[serviceName] = serviceDef.callStack.map (s) -> s.serviceName or s.filterName
  return output
