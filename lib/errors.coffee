error = require 'tea-error'

# Create a constructor for better errors
LawError = error 'LawError'

# subtypes = [
#   'FailedArgumentLookup'
#   'MissingArgument'
#   'InvalidArgument'
# ]
#

# Lots of copy-paste code, obvious shared structure in the class
# definitions below. Can this be factored out in a CS-idiomatic way?

class FailedArgumentLookupError extends LawError
  name: 'LawError/FailedArgumentLookup'

  constructor: (message, properties, callee) ->
    message = message or "Unspecified #{@name}"

    super message, properties, callee


class MissingArgumentError extends LawError
  name: 'LawError/MissingArgument'

  constructor: (message, properties, callee) ->
    message = message or "Unspecified #{@name}"

    super message, properties, callee


class InvalidArgumentError extends LawError
  name: 'LawError/InvalidArgument'

  constructor: (message, properties, callee) ->
    message = message or "Unspecified #{@name}"

    super message, properties, callee


module.exports = {
  LawError
  FailedArgumentLookupError
  MissingArgumentError
  InvalidArgumentError
}
