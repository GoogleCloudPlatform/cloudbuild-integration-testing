const chai = require('chai');
const chaiHttp = require('chai-http');
const expect = chai.expect;
const app = require('../app');
chai.use(chaiHttp);

describe('server', () => {
  it('should be listening', (done) => {
    chai.request(app)
      .get('/')
      .end((err, res) => {
        expect(res.status).to.equal(200);
        done();
      });
  });

  it('should 404 on nonexistent route', (done) => {
    chai.request(app)
      .get('/test')
      .end((err, res) => {
        expect(res.status).to.equal(404);
        done();
      });
  });
});
