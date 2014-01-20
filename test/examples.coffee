should = require 'should'
law = require '..'


serviceWithDep = ->
  doF: (args, next) -> next()
  doG:
    dependencies:
      services: ['doF']
    service: (args, next, deps) ->
      should.exist deps
      {services: {doF}} = deps
      should.exist doF
      next()


describe 'Public API', ->

  # # Description
  #   Convenience method: wrap services in complete middleware stack
  # # Parameters
  #   args : {
  #     services : [
  #       <serviceName>: <serviceDef>
  #     ]
  #     jargon: [JargonDef]
  #     policy: [PolicyDef]
  #     resolvers: [Arrayresolvers]
  #   }
  #   services : Array<ServiceDef>
  #     where ServiceDef :
  #       [jargon] :
  #       [policy]
  #       [resolvers]
  # # Returns
  #   {serviceName: serviceDef} (wrapped)
  describe 'create', ->

    it 'should work with a simple definition', (done) ->

      # Given a singleton collection of service definitions,
      # containing only a simple service definition, expressed
      # as a function of the signature (Object, Function)
      basicServices =
        doF: (args, next) ->

          # Which expects to be processing a first argument that exists
          should.exist args

          # And is an Object
          args.should.be.an.instanceOf Object

          next()

      # When we pass the service definitions to 'create'
      services = law.create {services: basicServices}

      # Then we should get back a wired-up collection of services
      should.exist services
      should.exist services.doF

      # With the service 'doF' still callable
      services.doF.should.be.an.instanceOf Function

      # But now has the keys we'd expect it to have if it
      # were processed as a Law service
      services.doF.should.have.keys [
        'serviceName'
        'callStack'
        'dependencies'
        'prepend'
      ]

      # And when we call it with a 'null' first argument
      # it passes its assertions and terminate.
      services.doF null, done

    it 'should work with a dependent service', (done) ->

      # Given a collection of service definitions
      complexServices =
        # With an service 'doF' that does nothing
        doF:
          service: (args, next) -> next()

        # And a service 'doG' that depends on 'doF'
        doG:
          dependencies:
            # Does recursive work?
            services: ['doF']
          service: (args, next, deps) ->

            # Which expects to be processing a first argument that exists
            should.exist args

            # And is an Object
            args.should.be.an.instanceOf Object

            # And which expects an object containing injected dependencies
            should.exist deps

            # Which contains injected 'service' dependencies
            should.exist deps.services

            # And in particular, contains our expected dependency 'doF'
            should.exist deps.services.doF

            # And which calls it
            deps.services.doF next

      # When we pass the service definitions to 'create'
      services = law.create {services: complexServices}

      # Then we should get back a wired-up collection of services
      should.exist services
      services.should.have.keys 'doF', 'doG'

      for name of services
        # The service should should be callable
        services[name].should.be.an.instanceOf Function

        # And now has the keys we'd expect it to have if it
        # were processed as a Law service
        services[name].should.have.keys [
          'serviceName'
          'callStack'
          'dependencies'
          'prepend'
        ]

      # And when we call the dependent service
      # it passes its assertions and terminate.
      services.doG null, done

    it 'should work with a required argument', (done) ->

      # Given a jargon definition
      jargon = [
        # Which defines a type whose value must be the string 'abc'
        typeName: 'abc'
        validation: (arg, assert) ->
          {abc} = args
          assert abc == 'abc'
        defaultArgs: []
      ]

      # And a service which requires an 'abc' argument, and does nothing
      # but verify that it received such an argument
      serviceDefs =
        doF:
          required: ['abc']
          service: (args, next) ->
            {abc} = args
            should.exist abc
            abc.should.eql 'abc'
            next()

      # When we create the services, passing the jargon definition
      services = law.create {
        services: serviceDefs
        jargon: jargon
      }
      should.exist services

      # It should pass its jargon-based type verifications when we call it
      services.doF {abc: 'abc'}, done

  # describe 'load', ->
  #   it '', (done) ->
  #     done()

  # processes service definitions into functions
  #   # accepts (services, jargon)
  #   # returns {serviceName: service}p
  describe 'applyMiddleware', ->
    beforeEach ->
      # Given a singleton collection of service definitions,
      # containing only a simple service definition, expressed
      # as a function of the signature (Object, Function)
      @serviceDefs =
        doF: (args, next) ->

          # Which expects to be processing a first argument that exists
          should.exist args

          # And is an Object
          args.should.be.an.instanceOf Object

          next()

    it 'should process service definitions into functions without a jargon def', (done) ->
      # When we pass the service definitions to 'applyMiddleware'
      services = law.applyMiddleware @serviceDefs

      # Then we should get back a wired-up collection of services
      should.exist services
      should.exist services.doF

      # With the service 'doF' still callable
      services.doF.should.be.an.instanceOf Function

      # But now has the keys we'd expect it to have if it
      # were processed as a Law service
      services.doF.should.have.keys [
        'serviceName'
        'callStack'
        'dependencies'
        'prepend'
      ]

      # And when we call it with a 'null' first argument
      # it passes its assertions and terminate.
      services.doF null, done

    it 'should process service definitions into functions with a jargon def', (done) ->
      # When we pass the service definitions to 'applyMiddleware'
      services = law.applyMiddleware @serviceDefs

      # Then we should get back a wired-up collection of services
      should.exist services
      should.exist services.doF

      # With the service 'doF' still callable
      services.doF.should.be.an.instanceOf Function

      # But now has the keys we'd expect it to have if it
      # were processed as a Law service
      services.doF.should.have.keys [
        'serviceName'
        'callStack'
        'dependencies'
        'prepend'
      ]

      # And when we call it with a 'null' first argument
      # it passes its assertions and terminate.
      services.doF null, done

  # describe 'applyPolicy', ->
  #   it '', (done) ->
  #     done()

  # describe 'applyDependencies', ->
  #   it '', (done) ->
  #     done()

  # describe 'printFilters', ->
  #   it '', (done) ->
  #     done()

  # describe 'graph', ->
  #   it '', (done) ->
  #     done()

  # describe 'errors', ->
  #   it '', (done) ->
  #     done()
