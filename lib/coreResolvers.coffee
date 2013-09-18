module.exports = (wrappedServices) ->
  services: (name) ->
    wrappedServices[name]
  require: (name) -> require(name)
