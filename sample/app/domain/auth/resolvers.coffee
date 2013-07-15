module.exports = (wrappedServices) ->
  services: (name) -> wrappedServices?[name]