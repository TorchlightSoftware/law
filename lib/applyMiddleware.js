const {getType} = require('./util');
const chain = require('./chain');
const lookupArgumentFilters = require('./lookupArgumentFilters');
const {ServiceDefinitionNoCallableError} = require('./errors');

module.exports = function(services, jargon) {

  if (jargon == null) jargon = []
  const wrappedServices = {};

  for (let serviceName in services) {
    const serviceDef = services[serviceName];

    // this closure captures context needed for the service call
    (function(serviceName, serviceDef) {

      const typeValidations = lookupArgumentFilters(serviceName, serviceDef, jargon);
      const service = serviceDef.service || serviceDef;
      const context = {serviceName};
      if (getType(service) !== 'Function')
        throw (new ServiceDefinitionNoCallableError(context));

      service.serviceName = serviceName;

      // return wrapped service
      var wrapper = function(params, done, dependencies) {
        if (arguments.length === 1) {
          done = params;
          params = {};
        }

        // execute the call stack
        chain(this, serviceName, params, wrapper.callStack, done, dependencies);
      };

      // attach meta-data
      wrapper.serviceName = serviceName;
      wrapper.callStack = [];
      wrapper.dependencies = serviceDef.dependencies || {};

      // expose a function for adding to the stack
      wrapper.prepend = function(services) {
        if (services && Array.isArray(services)) {
          wrapper.callStack.unshift(...services || []);
        } else if (getType(services) === 'Function') {
          wrapper.callStack.unshift(services);
        }
      };

      // build up static portion of call stack
      wrapper.prepend(service);
      wrapper.prepend(typeValidations);

      wrappedServices[serviceName] = wrapper;
    })(serviceName, serviceDef);
  }

  return wrappedServices;
};
