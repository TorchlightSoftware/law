const should = require('should');
const util = require('util');

const graph = require('../lib/graph');

const services = {
  s1: {
    dependencies: {
      services: ['s2', 's6']
    },
    service(args, done, deps) { done(); }
  },
  s2: {
    dependencies: {
      services: ['s3']
    },
    service(args, done, deps) { done(); }
  },
  s3: {
    dependencies: {
      services: ['s4', 's5']
    },
    service(args, done, deps) { done(); }
  },
  s4: {
    dependencies: {
      services: []
    },
    service(args, done, deps) { done(); }
  },
  s5: {
    dependencies: {
      services: []
    },
    service(args, done, deps) { done(); }
  },
  s6: {
    dependencies: {
      services: ['s1']
    },
    service(args, done, deps) { done(); }
  },
  s7: {
    dependencies: {
      services: []
    },
    service(args, done, deps) { done(); }
  }
};

const expectedResults = {
  services: {
    s1: ['s1', 's2', 's3', 's4', 's5', 's6'],
    s2: ['s2', 's3', 's4', 's5'],
    s3: ['s3', 's4', 's5'],
    s4: ['s4'],
    s5: ['s5'],
    s6: ['s1', 's2', 's3', 's4', 's5', 's6'],
    s7: ['s7']
  }
};

const expectedAdjacencyArray = [
  ['s1', 's2'],
  ['s1', 's6'],
  ['s2', 's3'],
  ['s3', 's4'],
  ['s3', 's5'],
  ['s6', 's1']
];

const expectedDot = `\
digraph Services {
  s1 -> s2;
  s1 -> s6;
  s2 -> s3;
  s3 -> s4;
  s3 -> s5;
  s6 -> s1;
}`;

describe('graph', function() {
  before(function(done) {
    should.exist(graph);
    done();
  });

  describe('graph.adjacentDependencies', function() {
    before(function(done) {
      should.exist(graph.adjacentDependencies);
      done();
    });

    it('should return adjacent services via default argument', function(done) {
      should.exist(services.s1);
      const adj = graph.adjacentDependencies(services, 's1');
      should.exist(adj);
      adj.should.eql(['s2', 's6']);
      done();
    });

    it('should return adjacent services when explicitly told to', function(done) {
      should.exist(services.s1);
      const adj = graph.adjacentDependencies(services, 's1', 'services');
      should.exist(adj);
      adj.should.eql(['s2', 's6']);
      done();
    });

    it('should return empty array when no services adjacent', function(done) {
      should.exist(services.s5);
      const adj = graph.adjacentDependencies(services, 's5');
      should.exist(adj);
      adj.should.be.empty;
      done();
    });
  });

  describe('graph.adjacencyRelation', function() {
    before(function(done) {
      should.exist(graph.adjacencyRelation);
      done();
    });

    it('should return an adjacency array of services via default argument', function(done) {
      const adj = graph.adjacencyRelation(services);
      should.exist(adj);
      adj.should.eql(expectedAdjacencyArray);
      done();
    });

    it('should return an adjacency array of services when told to', function(done) {
      const adj = graph.adjacencyRelation(services, 'services');
      should.exist(adj);
      adj.should.eql(expectedAdjacencyArray);
      done();
    });
  });

  describe('graph.connectedDependencies', function() {
    before(function(done) {
      should.exist(graph.connectedDependencies);
      done();
    });

    it('should return all (directed) connected services by default', function(done) {
      for (let name in services) {
        const def = services[name];
        const connected = graph.connectedDependencies(services, name);
        connected.should.eql(expectedResults.services[name]);
      }
      done();
    });

    it('should return all (directed) connected services when told to', function(done) {
      for (let dependencyType in expectedResults) {
        for (let name in services) {
          const def = services[name];
          const connected = graph.connectedDependencies(services, name, dependencyType);
          connected.should.eql(expectedResults[dependencyType][name]);
        }
      }
      done();
    });
  });

  describe('graph.dotNotation', function() {
    before(function(done) {
      should.exist(graph.dotNotation);
      done();
    });

    it('should return a string representation in dot notation by default', function(done) {
      const dot = graph.dotNotation(services, 'Services');
      dot.should.eql(expectedDot);
      done();
    });

    it('should return a string representation in dot notation when told to', function(done) {
      for (let dependencyType in expectedResults) {
        for (let name in services) {
          const def = services[name];
          const dot = graph.dotNotation(services, 'Services', dependencyType);
          dot.should.eql(expectedDot);
        }
      }
      done();
    });
  });
});
