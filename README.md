# Law

Less strictly constitutional and more strictly awesome.

Law lets you define services in a transport agnostic way.  Core features in Law are:

1. required/optional params
2. input validation
3. access control policy

Law services are "just javascript functions".  In our applications, we have connected these services to REST, websockets, gRPC, and a programmatic API through the use of various adapters.

![Build Status](https://api.travis-ci.org/TorchlightSoftware/law.png)


## Sample Service

The simplest way to define a service is as a bare function that takes a param object and a callback:

### getRole.js
```js
module.exports = ({sessionId, specialKey}, done) => {
  // check the sessionId against the database
  done null, {role: 'Supreme Commander'}
}
```

If you're writing anything important, you're going to want some input validations for your service.  Law lets you do this declaratively by defining your service as an object instead, with some special fields that tell Law what kind of rules you want to be applied:

### getRole.js
```js
module.exports = {
  required: ['sessionId'],
  optional: ['specialKey'],
  service({sessionId, specialKey}, done) {
    // check the sessionId against the database
    done null, {role: 'Supreme Commander'}
  }
}
```

When Law processes this definition, the end result is a *function with the same signature that you started with*.  So it still takes an object and a callback.  It just performs some validations before it runs your service.

## Sample Validations

Now, let's say you want to write some validations that do something more complex than just detect if the value exists.  Law provides a 'jargon' file for that, which you can think of as a set of type definitions.  Instead of being checked at compile time (e.g. TypeScript), they will be checked at runtime, whenever values from the outside world are being passed into your services.

You can also think of this as the language that a particular set of services share (Domain Driven Design).  Whenever these names are used in service arguments, their meanings will be enforced by the rules you set here.

Here's some example argument types, and their validations:

### jargon.js
```js
redisId = /[a-z0-9]{16}/
mongoId = /[a-f0-9]{24}/

module.exports = [
  {
    typeName: 'String'
    validation: (arg, assert) =>
      assert(typeof arg === 'string')
    defaultArgs: ['email', 'password', 'sessionId', 'userId']
  },
  {
    typeName: 'SessionId'
    validation: (arg, assert) =>
      assert(arg.match(redisId))
    defaultArgs: ['sessionId']
  },
  {
    typeName: 'MongoId'
    validation: (arg, assert) =>
      assert(arg.match(mongoId))
    defaultArgs: ['userId']
  }
]
```

Your validations just have to call `assert`, and in return you'll get beautiful error messages that tell you exactly what service was being called and which validation failed.

Here's an example policy file.  Filters are just regular services.  If one returns an error, the call stack stops and returns it, otherwise the results are merged into the argument object and passed on to the next service in the call stack.

### policy.js
```js
module.exports = {
  filterPrefix: 'filters',
  rules: [
    {
      filters: ['isLoggedIn'],
      except: ['getRole', 'login']
    },
    {
      filters: ['setIsOnline'],
      only: ['dashboard']
    }
  ]
}
```

## Why this is a good thing

Through this approach we accomplish the following:

1. Decoupling between validations and domain logic
2. Access control is described in one place
3. The preconditions for services are declarative

Standardizing on receiving arguments as an object allows Law to be very flexible and minimize your code maintenance costs.  You can always add new arguments, and new policy layers that are concerned with them.  Services that aren't concerned with the new arguments can ignore them and don't need to be modified.

Having your "domain language" explicit and in one file makes it very easy for newcomers to get familiar with the project.  Having the policy rules as a simple JSON object helps enormously in clarity, and to avoid mistakes in how they are applied.

Because the compositional tools are so good, we can write really small bits of code that are reusable.  This makes the code overall much easier to read and maintain.

Because the structure binding these pieces together is declarative, we can easily make it visible for analysis and troubleshooting.  Here is a printout from the sample application.

```js
#> console.debug(law.printFilters(services))

{ dashboard: [ 'filters/isLoggedIn', 'filters/setIsOnline', 'dashboard' ],
  'filters/isLoggedIn':
   [ 'sessionId.exists',
     'sessionId.isValid(SessionId)',
     'filters/isLoggedIn' ],
  'filters/setIsOnline': [ 'filters/setIsOnline' ],
  getRole: [ 'sessionId.exists', 'sessionId.isValid(SessionId)', 'getRole' ],
  login: [ 'login' ] }
```

This tells you exactly what's going to happen when the `login` service executes.

## Promise Support

As of 1.1.0, you can use promises and async functions with Law:

```js
module.exports = {
  required: ['sessionId'],
  optional: ['specialKey'],
  service: async ({sessionId, specialKey}) =>
    ({role: 'Supreme Commander'})
}
```

When you call a Law service, if you don't pass a callback, you'll get a Promise:

```js
services
  .getRole({sessionId})
  .then(results => console.debug(results))
  .catch(err => {throw err})
```

Knock yourself out.

## Dependencies (optional feature)

Since version 0.1.1 Law supports declarative dependency injection.  The two built in loaders are:

* services: call sibling services
* lib: a shortcut to require

This lets us do static analysis of dependencies, and can be used as a way of making side effects explicit.

```js
module.exports = {
    required: ['sessionId'],
    dependencies: {
      services: ['aHelperService'],
      lib: ['lodash']
    },

    service: (args, done, {services: {aHelperService}, lib: {lodash}}) => {
      args = lodash.merge({myOpt: 1}, args)
      aHelperService(args, done)
    }
}
```

To add more loaders, just plug in a resolvers object when you load your services:

```js
const resolvers = {
  myLoader: (name) => loadIt(name)
}

const services = law.create({services, jargon, policy, resolvers})
```

## Getting Started

```bash
npm install -S law
```

The only dependency is `tea-error` and the final package size is `11kB`.

Law is a library, not a framework, so it doesn't make assumptions about location of your files.  You'll need something like the following to initialize and connect the services when your application starts.

### initLaw.js
```js
const {join} = require('path')
const {load, create, printFilters} = require('law')

// files from the sample app
const serviceLocation = join(__dirname, '../sample/app/domain/auth/services')
const argTypes = require('../sample/app/domain/auth/jargon')
const policy = require('../sample/app/domain/auth/policy')

// services is just an object with {serviceName: serviceFn}
const services = load(serviceLocation)
const services = create({services, jargon, policy})
console.debug("I am the law:", printFilters(services))
```

Output:
```txt
{ dashboard: [ 'filters/isLoggedIn', 'filters/setIsOnline', 'dashboard' ],
  'filters/isLoggedIn':
   [ 'sessionId.exists',
     'sessionId.isValid(SessionId)',
     'filters/isLoggedIn' ],
  'filters/setIsOnline': [ 'filters/setIsOnline' ],
  getRole: [ 'sessionId.exists', 'sessionId.isValid(SessionId)', 'getRole' ],
  login: [ 'login' ] }
```

Now if you want to expose these via HTTP, you can use our [law-connect](https://github.com/torchlightsoftware/law-connect) plugin.  If you're using gRPC, websockets, or some other protocol, it should be just a few lines of code to create an adapter.  Let us know if you make an adapter for a new protocol and we'll link to it here!

## Further Reading

[Error Codes](docs/errors.md)

## Credit/Inspiration

Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.  The argument validations take some ideas from Design By Contract, e.g. preconditions.  Applying validators to default names was suggested by @JosephJNK.  I am interested to see if this will be conducive to creating a 'ubiquitous language' as described by Eric Evans in Domain Driven Design.

Many thanks to @wearefractal (@amurray, @contra), @JosephJNK, and @uberscientist for conversations and collaboration on application design with functional and declarative programming.

## The Fine Print

(MIT License)

Copyright (c) 2019 Torchlight Software <info@torchlightsoftware.com>

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
