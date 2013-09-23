# Law

Less strictly constitutional and more strictly awesome.

This project was motivated by the desire to take a lot of validation and error handling logic out of our services, and put it in a declarative layer.

Law is a middleware layer for tying together:

1. A set of services
2. Argument validations and lookups
3. An access control policy

Law is framework and transport agnostic.  Its focus is on enforcing the business rules specific to your application.  In our applications, we have connected these services to REST, websockets, and a programmatic API through the use of adapters.  I present below an example that should help to tie in as connect middleware.  Hopefully there will be enough information here to make this a useful tool for those interested.  If you're having trouble getting things working, let me know.

![Build Status](https://api.travis-ci.org/TorchlightSoftware/law.png)

## Credit/Inspiration

Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.  The argument validations take some ideas from Design By Contract, e.g. preconditions.  Applying validators to default names was suggested by @JosephJNK.  I am interested to see if this will be conducive to creating a 'ubiquitous language' as described by Eric Evans in Domain Driven Design.

The separation of Express and Connect has influenced our decision to do the same.  I think that while frameworks can lead to gains in terms of productivity, a library has greater potential for re-use.

Many thanks to @wearefractal (@amurray, @contra), @JosephJNK, and @uberscientist for conversations and collaboration on application design with functional and declarative programming.

## Application Files

Following are some possible uses of Law.  Further options are described in the [extended documentation].

Here's an example service.  Law will construct a function from this which will enforce the required/optional parameters.  Both optional and required parameters will run any associated validations.

### getRole.coffee
```coffee-script
module.exports =
  required: ['sessionId']
  optional: ['specialKey']
  service: ({sessionId, specialKey}, done) ->

    # check the sessionId against the database

    done null, {role: 'Supreme Commander'}
```

Here's some example argument types, and their validations.  Law makes these available in the definition of services.  You can think of them as the language that a particular set of services share.  Whenever these names are used in service arguments, their meanings will be enforced by the rules you set here.

### jargon.coffee
```coffee-script
redisId = /[a-z0-9]{16}/
mongoId = /[a-f0-9]{24}/

module.exports = [
    typeName: 'String'
    validation: (arg, assert) ->
      assert typeof arg is 'string'
    defaultArgs: ['email', 'password', 'sessionId', 'userId']
  ,
    typeName: 'SessionId'
    validation: (arg, assert) ->
      assert arg.match redisId
    defaultArgs: ['sessionId']
  ,
    typeName: 'MongoId'
    validation: (arg, assert) ->
      assert arg.match mongoId
    defaultArgs: ['userId']
]
```

Here's an example policy file.  The filters named here are defined as regular services, but they are run in a slightly different context.  If they return an error, the filter stack stops and returns it, otherwise their results are merged into the argument stream and passed on to the next service in the stack.

### policy.coffee
```coffee-script
module.exports =
  filterPrefix: 'filters'
  rules:
    [
      {
        filters: ['isLoggedIn']
        except: [
          'getRole'
          'login'
        ]
      }

      {
        filters: ['setIsOnline']
        only: ['dashboard']
      }
    ]
```

## Dependencies

Since version 0.1.1 Law supports declarative dependency injection.  The two built in loaders are:

* services: call sibling services
* lib: a shortcut to require

This lets us do static analysis of dependencies, and can be used as a way of making side effects explicit.

```coffee-script
module.exports =
  required: ['sessionId']
  dependencies:
    services: ['aHelperService']
    lib: ['lodash']

  service: (args, done, {services, require}) ->
    args = lib.lodash.merge {myOpt: 1}, args
    services.aHelperService args, done
```

To add more loaders, just plug in a resolvers object when you load your services:

```coffee-script
resolvers = {
  myLoader: (name) -> loadIt(name)
}

law.create {services, jargon, policy, resolvers}
```


## Value

Through this approach we accomplish the following:

1. Decoupling between validations and domain logic
2. Access control is described in one place
3. The preconditions for services are declarative

Because the structure binding these pieces together is declarative, we can easily make it visible for analysis and troubleshooting.  Here is a printout from the sample application.

```coffee-script
#> console.log law.printFilters services

{ dashboard: [ 'filters/isLoggedIn', 'filters/setIsOnline', 'dashboard' ],
  'filters/isLoggedIn':
   [ 'sessionId.exists',
     'sessionId.isValid(SessionId)',
     'filters/isLoggedIn' ],
  'filters/setIsOnline': [ 'filters/setIsOnline' ],
  getRole: [ 'sessionId.exists', 'sessionId.isValid(SessionId)', 'getRole' ],
  login: [ 'login' ] }
```

## Getting Started

```bash
npm install law
```

Before you can start using the facilities mentioned above in your app, you'll need to wire some things up.  This being a library intended to support a not-yet-released framework, no assumptions are made about the locations of your files.  You'll need something like the following to initialize and connect the services when your application starts.

### initLaw.coffee
```coffee-script
should = require 'should'
{join} = require 'path'

# lib stuff
connect = require 'connect'
{load, create, printFilters} = require 'law'

# files from the sample app
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
argTypes = require '../sample/app/domain/auth/jargon'
policy = require '../sample/app/domain/auth/policy'

services = load serviceLocation
services = create {services, jargon, policy}
console.log "I am the law:", printFilters services
```

This gives you a hash of {serviceName, serviceDef}.  Now if you wanted to use that, say as connect middleware, you could write up some basic routing like so.

### connectAdapter.coffee
```coffee-script
app = connect()
app.use (req, res) ->

  # find service to call, or return 404
  pathParts = req._parsedUrl.pathname.split('/').remove ''
  resourceName = pathParts[0]
  service = resourceMap[resourceName] or ->
    res.writeHead 404
    res.end()

  # call service
  service {
      url: req.url
      headers: req.headers
      query: req.query || {}
      pathParts: pathParts
      cookies: req.cookies
    }, res

```
## Error codes
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

## Further Reading

You can find [extended documentation here].

## Project Status

This should be considered an alpha release.  The API may change.  It was developed within an active project with the intent to only build the features which give us a clear advantage.  Additional features will be added as required for the parent project.

Discussion/feedback is welcome.  You can reach me on twitter @qbitmage.

Future goals/possibilities:

1. Unit tests for each component file.
2. Standard adapters for websocket RPC, REST
3. Enforce post-conditions?
4. Development of a contract-driven web framework.

## The Fine Print

(MIT License)

Copyright (c) 2013 Torchlight Software <info@torchlightsoftware.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
