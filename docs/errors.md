# Error codes
Law provides standard subtypes of `Error`, enriched using the `tea-error`
library (https://github.com/qualiancy/tea-error). This means a `properties`
object can be attached to the `Error` instance upon construction, as well
as an indicator of the function that the stack trace should start from.

We provide a `LawError` subtype of `Error` that acts as a common parent to
all the more specific error subtypes. Extensions to Law should extend this
type to obtain the benefits of `tea-error`, as well as permitting distinction
between instances of Law errors from application errors.

### LawError
Common parent type of errors within the Law library (and extensions).
Endowed with extra metadata couresty `tea-error`.

### FailedArgumentLookupError
Unused.

### InvalidArgumentError
An argument passed to a Law service exists, but has failed a validation.
Occurs at call time

### InvalidArgumentsObjectError
The `args` argument of a service call was not an instance of `object`.
Occurs at call time.

### InvalidServiceNameError
A serviceName that appears in the policy file has no referent amongst the actual
discovered services. Occurs when processing the policy file.

### MissingArgumentError
A required argument was not present in the `args` object passed to the service.
Occurs at call time.

### NoFilterArrayError
Thrown when a (malformed) rule in the policy file does not have any filters.
Occurs at setup time, when applying policy rules to services.

### ServiceDefinitionNoCallableError
A service definition did not provide a callable (instance of `function`).
Occurs when when wrapping services at setup time.

### ServiceDefinitionTypeError
The service definition was neither a function nor a richer service definition
object containing metadata and optional Law declarations. Occurs at setup time.

### ServiceReturnTypeError
The return value of a service (chained in a computed stack of services) is
not an object. Occurs at call time.

### UnresolvableDependencyError
A particular dependency in a valid (resolvable) dependency category could
not be resolved using the configuration given

### UnresolvableDependencyTypeError
A service declared an unresolvable dependency category. For example, if the
resolver configuration doesn't define a way to resolve dependencies in a
`services` category, this error would be thrown. Occurs at setup time, when
resolving dependencies.
