var web3UtilApi = require('../lib/web3-util');
const TEST_DATA = [
  {  args : [3,6,7,9], result: false},
  {  args : [3,6,6,9], result: true },
  {  args : [3,6,5,9], result: true },
  {  args : [3,6,0,9], result: true },
  {  args : [3,6,0,5], result: true },
  {  args : [3,6,0,2], result: false},
  {  args : [3,6,0,3], result: true}
].forEach(function(data, idx) {
  contract('2. intersect tests', function (accounts) {
    var immoRegistry;
    var resolveEvent;
    const OWNER_ACC = accounts[0];
    const LESSEE_ACC = accounts[1];
    const AgreementState = ['OFFERED', 'PENDING', 'ACTIVE', 'IN_CANCELATION', 'CANCELLED'];

    before(function () {
      resolveEvent = web3UtilApi(web3, [ImmoRegistry]).resolveEvent;
    });

    beforeEach(function () {
      immoRegistry = ImmoRegistry.deployed();
    });

    it(idx + ' intersects('+data.args+')=='+data.result+' is valid', function (done) {
      const x1 = data.args[0];
      const y1 = data.args[1];
      const x2 = data.args[2];
      const y2 = data.args[3];
      return immoRegistry.intersects(x1,y1,x2,y2).then(function(result){
        done();
        assert.equal(data.result,result,'intersect mismatch');
      });
    });
  });
});