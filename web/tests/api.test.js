const chai = require('chai');
const expect = chai.expect;
const getProducts = require('../api/getProducts');
const db = require('../db');
const sinon = require('sinon');

describe('getProducts', () => {
  it('should export a function', (done) => {
    expect(getProducts).to.be.a('function');
    done();
  });

  it('should throw err if db not connected', (done) => {
    const sandbox = sinon.createSandbox();
    sandbox.stub(process, 'env').value({ 'DB_HOST': 'some value' });
    const query = sandbox.stub(db, 'query');
    const expectedError = new Error('connection refused');
    query.throws(expectedError);

    getProducts().then(result => {
      expect(result).to.be.undefined;
    }).catch(err => {
      expect(err).to.equal(expectedError);
    });

    sandbox.restore();
    done();
  });

  it('should query database', (done) => {
    const sandbox = sinon.createSandbox();
    const mock = sandbox.mock(db);
    mock.expects('query').once().returnsThis;

    getProducts();
    mock.verify();

    sandbox.restore();
    done();
  });

  it('should use correct query', async (done) => {
    const sandbox = sinon.createSandbox();
    const query = sandbox.spy(db, 'query');
    const expectedQuery = 'SELECT name FROM product ORDER BY name';
    const callback = sinon.spy();

    getProducts(callback).catch(err => {
      expect(err).to.be.instanceOf(Error);
    });
    query.restore();
    
    sandbox.assert.calledWith(query, expectedQuery);

    sandbox.restore();
    done();
  });

  it('should return products if successful', (done) => {
    const sandbox = sinon.createSandbox();
    const expectedCookies = ['thin mint', 'chocolate chip'];
    var query = sandbox.stub(db, 'query');
    query.returns(expectedCookies);

    const result = getProducts()
      .then(result => {
        return result;
      }).catch(err => {
        done(err);
      });
    sandbox.assert.match(result, query);

    sandbox.restore();
    done();
  });

});

