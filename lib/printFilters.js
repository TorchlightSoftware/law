module.exports = function(services) {
  const output = {};
  for (let serviceName in services) {
    const serviceDef = services[serviceName];
    output[serviceName] = serviceDef.callStack.map(s => s.serviceName);
  }
  return output;
};
