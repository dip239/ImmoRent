var web3UtilApi = require('../lib/web3-util');

contract('2. State Change (HappyPath)', function(accounts) {
  var immoRegistry;
  var resolveEvent;
  const OWNER_ACC   = accounts[0];
  const LESSOR_ACC  = accounts[0];
  const LESSEE_ACC  = accounts[1];
  const AgreementState = ['OFFERED', 'PENDING', 'ACTIVE', 'LESSOR_CANCEL', 'LESSEE_CANCEL', 'CLOSED', 'REJECTED'];

  before(function() {
    resolveEvent = web3UtilApi(web3, [ImmoRegistry]).resolveEvent;
  });

  beforeEach(function() {
    immoRegistry = ImmoRegistry.deployed();
  });

  it('creates new valid immo is valid', function(){
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

  var theAgreementNr;

  it('creates new valid RentalAgreement offer', function(){
    const IMMO_ID = 0;
    const DISPLAY_NAME = 'immohouse334';
    const FROM_DATE = 10;
    const TO_DATE = 20;
    return immoRegistry.createImmoOffer(IMMO_ID,FROM_DATE,TO_DATE, {from:OWNER_ACC})
        .then(resolveEvent('NewRentalAgreement(uint256)'))
        .then(function(agreementNr) {
          return immoRegistry.rentalAgreements(agreementNr);
        }).then(function(agreement) {
          var agreementNr = agreement[0].valueOf();
          assert.equal(0           ,agreementNr ,'agreement.id mismatch');
          assert.equal(IMMO_ID     ,agreement[1],'immo id mismatch');
          assert.equal(OWNER_ACC   ,agreement[2],'lessor account mismatch');
          assert.equal(0           ,agreement[3],'lessee account mismatch');
          assert.equal(FROM_DATE   ,agreement[4],'from date mismatch');
          assert.equal(TO_DATE     ,agreement[5],'to date mismatch');
          assert.equal('OFFERED'   ,AgreementState[agreement[6]], 'state mismatch');
          return theAgreementNr = agreementNr;
        });
  });

  it('lessee accepts the offer', function(){
    var IMMO_ID = 0;
    return immoRegistry.acceptRentalAgreement(theAgreementNr, {from:LESSEE_ACC})
        .then(resolveEvent('RentalAgreementStateChange(uint256,uint8,uint8)'))
        .then(function(eventInfo) {
          assert.equal(theAgreementNr,eventInfo[0],'agreement.id mismatch');
          assert.equal('OFFERED'     ,AgreementState[eventInfo[1]],'immo id mismatch');
          assert.equal('PENDING'     ,AgreementState[eventInfo[2]],'lessor account mismatch');
          return immoRegistry.rentalAgreements(eventInfo[0]);
        }).then(function(agreement) {
          var agreementNr = agreement[0].valueOf();
          assert.equal(theAgreementNr,agreementNr,'agreement.id mismatch');
          assert.equal(OWNER_ACC     ,agreement[2],'lessor account mismatch');
          assert.equal(LESSEE_ACC    ,agreement[3],'lessee account mismatch');
          return agreementNr;
        });
   });

  it('lessor starts the contract', function(){
    return immoRegistry.startRentalAgreement(theAgreementNr, {from:LESSOR_ACC})
        .then(resolveEvent('RentalAgreementStateChange(uint256,uint8,uint8)'))
        .then(function(eventInfo) {
          assert.equal(theAgreementNr,eventInfo[0],'agreement.id mismatch');
          assert.equal('PENDING'     ,AgreementState[eventInfo[1]],'immo id mismatch');
          assert.equal('ACTIVE'     ,AgreementState[eventInfo[2]],'lessor account mismatch');
          return immoRegistry.rentalAgreements(eventInfo[0]);
        }).then(function(agreement) {
          var agreementNr = agreement[0].valueOf();
          assert.equal(theAgreementNr,agreementNr,'agreement.id mismatch');
          assert.equal(OWNER_ACC     ,agreement[2],'lessor account mismatch');
          assert.equal(LESSEE_ACC    ,agreement[3],'lessee account mismatch');
          return agreementNr;
        });
  });
});
