should = require 'should'
util = require 'util'

graph = require '../lib/graph'

services =
  s1:
    dependencies:
      services: ['s2', 's6']
    service: (args, done, deps) -> done()
  s2:
    dependencies:
      services: ['s3']
    service: (args, done, deps) -> done()
  s3:
    dependencies:
      services: ['s4', 's5']
    service: (args, done, deps) -> done()
  s4:
    dependencies:
      services: []
    service: (args, done, deps) -> done()
  s5:
    dependencies:
      services: []
    service: (args, done, deps) -> done()
  s6:
    dependencies:
      services: ['s1']
    service: (args, done, deps) -> done()
  s7:
    dependencies:
      services: []
    service: (args, done, deps) -> done()

expectedResults =
  services:
    s1: ['s1', 's2', 's3', 's4', 's5', 's6']
    s2: ['s2', 's3', 's4', 's5']
    s3: ['s3', 's4', 's5']
    s4: ['s4']
    s5: ['s5']
    s6: ['s1', 's2', 's3', 's4', 's5', 's6']
    s7: ['s7']

describe 'graph', ->
  before (done) ->
    should.exist graph
    done()

  describe 'graph.adjacentDependencies', ->
    before (done) ->
      should.exist graph.adjacentDependencies
      done()

    it 'should return adjacent services via default argument', (done) ->
      should.exist services.s1
      adj = graph.adjacentDependencies services, 's1'
      should.exist adj
      adj.should.eql ['s2', 's6']
      done()

    it 'should return adjacent services when explicitly told to', (done) ->
      should.exist services.s1
      adj = graph.adjacentDependencies services, 's1', 'services'
      should.exist adj
      adj.should.eql ['s2', 's6']
      done()      

    it 'should return empty array when no services adjacent', (done) ->
      should.exist services.s5
      adj = graph.adjacentDependencies services, 's5'
      should.exist adj
      adj.should.be.empty
      done()

  describe 'graph.connectedDependencies', ->
    before (done) ->
      should.exist graph.connectedDependencies
      done()

    it 'should return all (directed) connected services by default', (done) ->
      for name, def of services
        connected = graph.connectedDependencies services, name
        connected.should.eql expectedResults.services[name]
      done()

    it 'should return all (directed) connected services when told to', (done) ->
      for dependencyType of expectedResults
        for name, def of services
          connected = graph.connectedDependencies services, name, dependencyType
          connected.should.eql expectedResults[dependencyType][name]
      done()
