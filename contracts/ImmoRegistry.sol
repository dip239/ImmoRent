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

    function createImmo(uint priceMonthly, bytes description, bytes externalInfo) {
        var id = immos.length;
        immos.push(
            Immo(id, msg.sender, priceMonthly, description, externalInfo)
        );
        NewImmo(id);
    }

    function rejectOtherAgreements(uint agreementNr) private {
      //ToDo:
    }

    function intersects(uint start1, uint end1, uint start2, uint end2) private returns (bool){
        //ToDo:
        return (start1>=start2 && end1<=start2) || (start1>=start2 && end1<=start2);
    }

    modifier onlyFreeImmo(uint agreementId){
  /*    //(uint immoId, uint fromDate, uint toDate)
        if (immoId >= immos.length) throw;
        for(uint i=0;i<rentalAgreements.length;++i){
            if (immoId == rentalAgreements[i].immoId) {
                if (intersects(fromDate, toDate, rentalAgreements[i].fromDate, rentalAgreements[i].fromDate)) throw;
            }
        }
   */
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

    function createImmoOffer(uint immoId, uint fromDate, uint toDate)
        onlyOwner(immoId)
    {
        var id = rentalAgreements.length;
        rentalAgreements.push(
            RentalAgreement(id, immoId, msg.sender, address(0x0), fromDate, toDate, AgreementState.OFFERED)
        );
        NewRentalAgreement(id);
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

    event NewImmo(uint immoId);
    event NewRentalAgreement(uint rentalAgreementId);
    event RentalAgreementStateChange(uint rentalAgreementId, AgreementState from, AgreementState to);
}