const should = require('should');
const {join} = require('path');

// lib stuff
const {load, applyDependencies, create} = require('../lib/main');

// sample stuff
const jargon = require('../sample/app/domain/auth/jargon');
const serviceLocation = join(__dirname, '../sample/app/domain/auth/services');
const policy = require('../sample/app/domain/auth/policy');

describe('dependency', function() {
  beforeEach(function(done) {
    const services = load(serviceLocation);
    this.services = create({services, jargon, policy});

    this.sessionId = 'ab23ab23ab23ab23';
    should.exist(this.services.doSomething);
    should.exist(this.services.helpDoSomething);

    done();
  });

  it('should not fail on a service with no dependencies', function(done) {
    this.services.helpDoSomething({sessionId: this.sessionId}, (err, {result}) => {
      should.not.exist(err);
      should.exist(result);
      result.should.equal('it worked');
      done();
    });
  });

  it('should reference a service', function(done) {
    this.services.doSomething({sessionId: this.sessionId}, (err, {result}) => {
      should.not.exist(err);
      should.exist(result);
      result.should.equal('it worked');
      done();
    });
  });

  it('should reference a lib', function(done) {
    this.services.useLib({sessionId: this.sessionId}, (err, result) => {
      should.exist(err);
      err.message.should.equal('testing special error')
      done();
    });
  });
});

  //it "should accept the resolvers data structure in 'create'", (done) ->
    //@services.doSomething {@sessionId}, (err) ->
      //should.not.exist err
      //done()

  //it 'should allow usage of a parameterized resolvers file', (done) ->
    //@services.doSomething {@sessionId}, (err) ->
      //should.not.exist err
      //done()
