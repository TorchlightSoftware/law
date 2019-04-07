module.exports = wrappedServices => ({
  services(name) {
    if (name === 'handleStar') return wrappedServices
    return wrappedServices[name]
  },
  lib(name) {
    return require(name)
  },
})
