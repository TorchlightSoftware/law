# Law

Law was designed to be a low level tool for tying together:

1. A set of services
2. Argument validations and lookups
3. An access control policy

Law lets you build services which are framework and transport agnostic. Its focus is on enforcing the business rules specific to your application.  In our applications, we have connected these services to REST, websockets, and a programmatic API through the use of adapters.  I present below an example that should help to tie in as connect middleware.  Hopefully there will be enough information here to make this a useful tool for those interested.  If you're having trouble getting things working, let me know.

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

### argumentTypes.coffee
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

## Value

Through this approach we accomplish the following:

1. Decoupling between validations and domain logic
2. Access control is described in one place
3. The preconditions for services are declarative

Because the structure binding these pieces together is declarative, we can easily make it visible for analysis and troubleshooting.  Here is a printout from the sample application.

```coffee-script
#> console.log law.print services

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
{create, print} = require 'law'

# files from the sample app
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
argTypes = require '../sample/app/domain/auth/argumentTypes'
policy = require '../sample/app/domain/auth/policy'

services = create serviceLocation, argTypes, policy
console.log "I am the law:", print services
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

## Inspiration / Credit

Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.  The argument validations take some ideas from Design By Contract, e.g. preconditions.  Applying validators to default names was suggested by @JosephJNK.  I am interested to see if this will be conducive to creating a 'ubiquitous language' as described by Eric Evans in Domain Driven Design.

The separation of Express and Connect has influenced our decision to do the same.  I think that while frameworks can lead to gains in terms of productivity, a library has greater potential for re-use.

Many thanks to @wearefractal (@amurray, @contra), @JosephJNK, and @uberscientist for conversations and collaboration on application design with functional and declarative programming.

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
