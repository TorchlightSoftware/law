module.exports =
  dependencies:
    services: ['helpDoSomething']
  required: []
  service: (args, done, deps) ->
    console.log '[doSomething]', {deps}
    {services} = deps
    services?.helpDoSomething args, done
