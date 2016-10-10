//   @morden_testnet 0xc78281a36b2d01d6f3c11f74625c7492d2dbc35f
//pragma solidity ^0.4.2;
contract ImmoRegistry {
    function() { throw; } // reject money sent to the contract.
    string public constant VERSION = "0.01-ImmoRegistry";

    enum AgreementState { OFFERED, PENDING, ACTIVE, LESSOR_CANCEL, LESSEE_CANCEL, CLOSED, REJECTED }

    struct Immo {
        uint id;
        address owner;
        uint priceMonthly;
        bytes displayname;
        bytes externalInfo;
    }

    struct RentalAgreement {
        uint id;
        uint immoId;
        address lessor;
        address lessee;
        uint fromDate;
        uint toDate;
        AgreementState state;
    }

    RentalAgreement[] public rentalAgreements;
    Immo[] public immos;

    function immosLength() constant returns (uint){
       return immos.length;
    }

    function rentalAgreementsLength() constant returns (uint){
       return rentalAgreements.length;
    }

//======== START factory methods

    function createImmo(uint priceMonthly, bytes description, bytes externalInfo) {
        var id = immos.length;
        immos.push(
            Immo(id, msg.sender, priceMonthly, description, externalInfo)
        );
        NewImmo(id);
    }

    function createImmoOffer(uint immoId, uint fromDate, uint toDate)
        onlyOwner(immoId)
    {
        var id = rentalAgreements.length;
        rentalAgreements.push(
            RentalAgreement(id, immoId, msg.sender, address(0x0), fromDate, toDate, AgreementState.OFFERED)
        );
        NewRentalAgreement(id);
    }

    function cancelImmoOffer(uint immoId)
        onlyOwner(immoId)
    {
        for(uint i=0; i < rentalAgreements.length; ++i) {
            if (rentalAgreements[i].immoId == immoId) {
                var state = rentalAgreements[i].state;
                if (state == AgreementState.OFFERED || state == AgreementState.PENDING
                   || state == AgreementState.LESSOR_CANCEL || state == AgreementState.LESSEE_CANCEL) {
                    rentalAgreements[i].state = AgreementState.REJECTED;
                    RentalAgreementStateChange(i,state,AgreementState.REJECTED);
                }
            }
        }
    }

    function acceptRentalAgreement(uint agreementNr)
        onlyAgreementState(agreementNr,AgreementState.OFFERED)
    {
        rentalAgreements[agreementNr].lessee = msg.sender;
        rentalAgreements[agreementNr].state = AgreementState.PENDING;
    }

    function startRentalAgreement(uint agreementNr)
        onlyLessor(agreementNr)
        onlyAgreementState(agreementNr,AgreementState.PENDING)
        onlyFreeImmo(agreementNr)
    {
        rentalAgreements[agreementNr].state = AgreementState.ACTIVE;
        rejectOtherAgreements(agreementNr);
    }

    function askCancelationByLessor(uint agreementNr)
        onlyAgreementState(agreementNr,AgreementState.ACTIVE)
        onlyLessor(agreementNr)
    {
        rentalAgreements[agreementNr].state = AgreementState.LESSOR_CANCEL;
    }

    function askCancelationByLessee(uint agreementNr)
        onlyAgreementState(agreementNr,AgreementState.ACTIVE)
        onlyLessee(agreementNr)
    {
        rentalAgreements[agreementNr].state = AgreementState.LESSEE_CANCEL;
    }

    function confirmCancelationByLessor(uint agreementNr)
        onlyAgreementState(agreementNr,AgreementState.LESSEE_CANCEL)
        onlyLessor(agreementNr)
    {
        rentalAgreements[agreementNr].state = AgreementState.CLOSED;
    }

    function confirmCancelationByLessee(uint agreementNr)
        onlyAgreementState(agreementNr,AgreementState.LESSOR_CANCEL)
        onlyLessee(agreementNr)
    {
        rentalAgreements[agreementNr].state = AgreementState.CLOSED;
    }

//======== START modifiers
    modifier onlyFreeImmo(uint agreementId){
        if (agreementId >= rentalAgreements.length) throw;
        for(uint i=0;i<rentalAgreements.length;++i){
            if (timeIntersects(i,agreementId)) throw;
        }
        _
    }

    modifier onlyAgreementState(uint id, AgreementState state) {
        if (rentalAgreements[id].state!=state) throw;
        _
    }

    modifier onlyOwner(uint immoId) {
        if (immos[immoId].owner!=msg.sender) throw;
        _
    }

    modifier onlyLessor(uint agreementId) {
        if (rentalAgreements[agreementId].lessor!=msg.sender) throw;
        _
    }

    modifier onlyLessee(uint agreementId) {
        if (rentalAgreements[agreementId].lessee!=msg.sender) throw;
        _
    }

//======== END modifiers

// === START helpers
    function rejectOtherAgreements(uint exceptAgreementNr) private {
        var theImmoId = rentalAgreements[exceptAgreementNr].immoId;
        for(uint i=0; i < rentalAgreements.length; ++i) {
          if (i != exceptAgreementNr) {
              if (timeIntersects(i, exceptAgreementNr)) {
                var state = rentalAgreements[i].state;
                rentalAgreements[i].state = AgreementState.REJECTED;
                RentalAgreementStateChange(i,state,AgreementState.REJECTED);
              }
          }
        }
    }

    function intersects(uint x1, uint y1, uint x2, uint y2) constant returns (bool){
        return  (x1 >= y1 && x1 <= y2) ||
                (x2 >= y1 && x2 <= y2) ||
                (y1 >= x1 && y1 <= x2) ||
                (y2 >= x1 && y2 <= x2);
    }

    function timeIntersects(uint agreementId1, uint agreementId2) constant returns (bool){
        var a1 = rentalAgreements[agreementId1];
        var a2 = rentalAgreements[agreementId2];
        return a1.immoId == a2.immoId
            && intersects(a1.fromDate, a1.toDate, a2.fromDate, a2.toDate);
    }

// === END helpers


    event NewImmo(uint immoId);
    event NewRentalAgreement(uint rentalAgreementId);
    event RentalAgreementStateChange(uint rentalAgreementId, AgreementState from, AgreementState to);
}