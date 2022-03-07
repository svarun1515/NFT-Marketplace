// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC721.sol";

contract Market{

    enum ListingStatus{
        Active,
        Sold,
        Cancelled
    }

    struct Listing{
        ListingStatus status;
        address seller;
        address token;
        uint tokenid;
        uint price;
    }

    event Listed(
        uint listingid,
        address seller,
        address token,
        uint tokenid,
        uint price
    );

    event Sale(
        uint listingid,
        address buyer,
        address token,
        uint price
    );

    event Cancel(
        uint listingid,
        address seller
    );

    uint private _listingid = 0;

    mapping(uint => Listing) private _listings;
    function listToken(address token, uint tokenid, uint price) external{
        IERC721(token).transferFrom(msg.sender, address(this), tokenid);

        Listing memory list = Listing(
            ListingStatus.Active,
            msg.sender,
            token,
            tokenid,
            price
        );

        _listingid++;
         _listings[_listingid] = list;

         emit Listed(
             _listingid,
             msg.sender,
             token,
             tokenid,
             price 
         );

    }

    function getListing(uint listingid) public view returns(Listing memory) {
        return _listings[listingid];
    }

    function buytoken(uint listingid) external payable {
       Listing storage listing = _listings[_listingid];

       require(listing.status == ListingStatus.Active,"Listing is not active");
       require(msg.sender != listing.seller, "Seller cannot be the buyer");

       require(msg.value >= listing.price, "Insufficient Funds");

       listing.status = ListingStatus.Sold;

       IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenid);
       payable(listing.seller).transfer(listing.price);

       emit Sale(
           listingid,
           msg.sender,
           listing.token,
           listing.price
       );
    }

    function cancel(uint listingid) public{
        Listing storage listing = _listings[listingid];

        require(listing.status == ListingStatus.Active, "Listing is not active");
        require(msg.sender == listing.seller,"Only seller can cancel listing");

        listing.status = ListingStatus.Cancelled;

        IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokenid);

        emit Cancel(
            listingid,
            listing.seller
        );
    }
}