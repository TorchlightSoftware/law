should = require 'should'

describe 'merge', ->
  it 'should merge two objects', ->
    {merge} = require '../lib/util'

    scenarios = [
      # left, right, expected, comment
      [{}, {}, {}, 'two empty objs => empty obj']
      [{}, {a: 1}, {a: 1}, 'empty, present => present']
      [{a: 1}, {}, {a: 1}, 'present, empty => present']
      [{a: 1}, {b: 2}, {a: 1, b: 2}, 'non conflicting results should coexist']
      [{a: 1}, {a: 2}, {a: 2}, 'in a conflict the right side should win']
    ]

    for scen in scenarios
      [left, right, expected, comment] = scen

      merge(left, right).should.eql expected, comment
