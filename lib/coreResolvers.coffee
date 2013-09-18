module.exports = (wrappedServices) ->
  services: (name) ->
    wrappedServices[name]
  lib: (name) -> require(name)
