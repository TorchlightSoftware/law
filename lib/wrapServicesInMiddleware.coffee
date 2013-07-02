{getType} = require './util'
chain = require './chain'
lookupArgumentFilters = require './lookupArgumentFilters'

module.exports = (services, jargon) ->

  wrappedServices = {}
  for serviceName, serviceDef of services
    do (serviceName, serviceDef) ->

      typeValidations = lookupArgumentFilters serviceName, serviceDef, jargon
      service = serviceDef.service or serviceDef
      throw new Error "Could not find function definition for service '#{serviceName}'." unless getType(service) is 'Function'
      service.serviceName = serviceName

      # return wrapped service
      wrapper = (params, done) ->

        # execute the call stack
        chain serviceName, params, wrapper.callStack, done

      # attach meta-data
      wrapper.serviceName = serviceName
      wrapper.callStack = []
      wrapper.dependencies = serviceDef.dependencies || {}

      # expose a function for adding to the stack
      wrapper.prepend = (services) ->
        if services and Array.isArray services
          wrapper.callStack.unshift services...
        else if getType(services) is 'Function'
          wrapper.callStack.unshift services

      # build up static portion of call stack
      wrapper.prepend service
      wrapper.prepend typeValidations

      wrappedServices[serviceName] = wrapper

  return wrappedServices
