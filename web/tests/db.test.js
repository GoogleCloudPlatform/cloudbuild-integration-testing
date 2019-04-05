const chai = require('chai');
const expect = chai.expect;
const db = require('../db');

describe('db pool', () => {
  it('should export an object', (done) => {
    expect(db).to.be.a('object');
    done();
  });
  it('should export query function', (done) => {
    expect(db.query).to.be.a('function');
    done();
  });
});