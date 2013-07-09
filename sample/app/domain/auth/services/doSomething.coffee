module.exports =
  dependencies:
    services: ['helpDoSomething']
  required: []
  service: (args, done, {services}) ->
    services.helpDoSomething args, done
