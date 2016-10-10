var web3UtilApi = require('../lib/web3-util');

contract('1. ImmoRegistry Create', function(accounts) {
  var immoRegistry;
  var resolveEvent;
  const OWNER_ACC  = accounts[0];
  const LESSEE_ACC = accounts[1];
  const AgreementState = ['OFFERED', 'PENDING', 'ACTIVE', 'LESSOR_CANCEL', 'LESSEE_CANCEL', 'CLOSED', 'REJECTED'];

  before(function() {
    resolveEvent = web3UtilApi(web3, [ImmoRegistry]).resolveEvent;
  });

  beforeEach(function() {
    immoRegistry = ImmoRegistry.deployed();
  });

  it('new Immo is valid', function(){
    const MONTHLY_RATE = 333;
    const DISPLAY_NAME = 'immohouse112';
    const BLOB_HEX = {foo: "bar"};
    return immoRegistry.createImmo(MONTHLY_RATE,DISPLAY_NAME,web3.toHex(BLOB_HEX))
      .then(resolveEvent('NewImmo(uint256)'))
      .then(function(immoNr) {
        return immoRegistry.immos(immoNr);
      }).then(function(immo) {
        immo[3] = web3.toUtf8(immo[3]);
        assert.equal(0           ,immo[0].valueOf(),'immo.id mismatch');
        assert.equal(accounts[0]  ,immo[1],'owner mismatch');
        assert.equal(MONTHLY_RATE,immo[2],'price mismatch');
        assert.equal(DISPLAY_NAME,immo[3],'display name mismatch');
        assert.deepEqual(BLOB_HEX,JSON.parse(web3.toUtf8(immo[4])),'immo.id mismatch');
        return immo;
      });
  });

  it('new RentalAgreement is valid', function(){
    const IMMO_ID = 0;
    const DISPLAY_NAME = 'immohouse112';
    const FROM_DATE = 1;
    const TO_DATE = 2;
    return immoRegistry.createImmoOffer(IMMO_ID,FROM_DATE,TO_DATE, {from:OWNER_ACC})
        .then(resolveEvent('NewRentalAgreement(uint256)'))
        .then(function(agreementNr) {
          return immoRegistry.rentalAgreements(agreementNr);
        }).then(function(agreement) {
          assert.equal(0           ,agreement[0].valueOf(),'agreement.id mismatch');
          assert.equal(IMMO_ID     ,agreement[1],'immo id mismatch');
          assert.equal(OWNER_ACC   ,agreement[2],'lessor account mismatch');
          assert.equal(0           ,agreement[3],'lessee account mismatch');
          assert.equal(FROM_DATE   ,agreement[4],'from date mismatch');
          assert.equal(TO_DATE     ,agreement[5],'to date mismatch');
          assert.equal('OFFERED'   ,AgreementState[agreement[6]], 'state mismatch');
          return agreement;
        });
  });

});
