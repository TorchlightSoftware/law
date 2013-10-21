{getType} = require './util'
chain = require './chain'
lookupArgumentFilters = require './lookupArgumentFilters'
{ServiceDefinitionNoCallableError} = require './errors'

module.exports = (services, jargon=[]) ->

  wrappedServices = {}
  for serviceName, serviceDef of services
    do (serviceName, serviceDef) ->

      typeValidations = lookupArgumentFilters serviceName, serviceDef, jargon
      service = serviceDef.service or serviceDef
      context =
        serviceName: serviceName
      throw (new ServiceDefinitionNoCallableError context) unless getType(service) is 'Function'
      service.serviceName = serviceName

      # return wrapped service
      wrapper = (params, done, dependencies) ->
        if arguments.length is 1
          done = params
          params = {}

        # execute the call stack
        chain @, serviceName, params, wrapper.callStack, done, dependencies

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
