module.exports =
  dependencies:
    services: ['helpDoSomething']
  required: []
  service: (args, done, deps) ->
    {services} = deps
    services?.helpDoSomething args, done
