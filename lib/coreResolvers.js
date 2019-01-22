module.exports = wrappedServices => ({
  services(name) {
    return wrappedServices[name];
  },
  lib(name) {return require(name);}
})
