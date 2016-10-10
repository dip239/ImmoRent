//   @morden_testnet 0xc78281a36b2d01d6f3c11f74625c7492d2dbc35f
//pragma solidity ^0.4.2;
contract ImmoRegistry {
    function() { throw; } // reject money sent to the contract.
    string public constant VERSION = "0.01-ImmoRegistry";

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
        address lessee;
        uint fromDate;
        uint toDate;
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

    function intersects(uint start1, uint end1, uint start2, uint end2) private returns (bool){
        return (start1>=start2 && end1<=start2) || (start1>=start2 && end1<=start2);
    }

    modifier onlyFreeImmo(uint immoId, uint fromDate, uint toDate){
        if (immoId >= immos.length) throw;
        for(uint i=0;i<rentalAgreements.length;++i){
            if (immoId == rentalAgreements[i].immoId) {
                if (intersects(fromDate, toDate, rentalAgreements[i].fromDate, rentalAgreements[i].fromDate)) throw;
            }
        }
        _
    }

    function createRentalAgreement(uint immoId, uint fromDate, uint toDate)
//        onlyFreeImmo(immoId, fromDate, toDate)
    {
        var id = rentalAgreements.length;
        rentalAgreements.push(
            RentalAgreement(id, immoId, msg.sender, fromDate, toDate)
        );
        NewRentalAgreement(id);
    }

    event NewImmo(uint immoId);
    event NewRentalAgreement(uint rentalAgreementId);
}