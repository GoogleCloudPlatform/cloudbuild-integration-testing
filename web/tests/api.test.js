const chai = require('chai');
const chaiHttp = require('chai-http');
// eslint-disable-next-line no-unused-vars
const should = chai.should();
const app = require('../app');

chai.use(chaiHttp);

describe('server', () => {
    it('it should be listening', (done) => {
        chai.request(app)
            .get('/')
            .end((err, res) => {
                res.should.have.status(200);
                done();
            });
    });
    it('it should 404 on nonexistent route', (done) => {
        chai.request(app)
            .get('/test')
            .end((err, res) => {
                res.should.have.status(404);
                done();
            });
    });
});
