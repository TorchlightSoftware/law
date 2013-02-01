{merge} = require './util'

module.exports = (name, service) ->
  wrapped = (args, next) ->
    service args, (err, results) ->

      # merge the results of the filter
      final = {}
      merge final, args unless err
      merge final, results

      # call the next function in the stack
      next err, final

  wrapped.serviceName = name
  return wrapped
