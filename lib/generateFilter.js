const {merge} = require('./util')

module.exports = function(name, service) {
  const wrapped = (args, next) =>
    service(args, function(err, results) {
      // merge the results of the filter
      const final = {}
      if (!err) {
        merge(final, args)
      }
      merge(final, results)

      // call the next function in the stack
      next(err, final)
    })
  wrapped.serviceName = name
  return wrapped
}
