{merge} = require './util'

module.exports = (name, service) ->
  wrapped = (args, next) ->
    service args, (err, results) ->
      return next err, args if err or not results

      # merge the results of the filter
      final = {}
      merge final, args
      merge final, results

      # call the next function in the stack
      next null, final

  wrapped.filterName = name
  return wrapped
