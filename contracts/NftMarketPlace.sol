//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity >=0.8.0;

error NftMarketPlace__PriceMustBeAboveZero();
error NftMarketPlace__NftNotApprovedForListing();
error NftMarketPlace__AlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketPlace__NotOwner();
error NftMarketPlace__NotListed(address nftAddress, uint256 tokenId);
error NftMarketPlace__PriceNotEnough(address nftAddress, uint256 tokenId, uint256 price);
error NftMarketPlace__NoProceeds();
error NftMarketPlace__TransferFailed();

contract NftMarketPlace is ReentrancyGuard{

    struct Listing {
        uint256 price;
        address seller;
    }

    event ItemListed (
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId, 
        uint256 price
    ); //indexed makes it easier to search for the event which is logged// max 3 indexed are allowed

    event ItemBought (
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemCanceled (
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    // NFT contract address -> NFT token -> Listing(price,seller) (read "->" as "mapped-to)
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    // seller address -> amount earned
    mapping(address => uint256) private s_proceeds;

    //Modifier to make sure that we don't re-list an already listed Nft
    modifier alreadyListed (address nftAddress, uint256 tokenId, address owner) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price > 0) {
            revert NftMarketPlace__AlreadyListed(nftAddress, tokenId);
        }
        _;
    }

    //Modifier to make sure that the NFT that is being listed is owned by msg.sender 
    modifier isOwner (address nftAddress, uint256 tokenId, address spender) 
    {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId); // { ownerOf(uint256 tokenId) returns (address owner) }
        if (spender != owner) {
            revert NftMarketPlace__NotOwner();
        }
        _;
    }

    //modifier to make sure that the item that we want to buy is listed
    modifier isListed (address nftAddress, uint256 tokenId) 
    {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.price <= 0) {
            revert NftMarketPlace__NotListed(nftAddress, tokenId);
        }
        _;
    }

    //nftAddress: address of the NFT that is to be listed in the market place
    // tokenId: tokenId of the NFT  "--"
    // price: sale price of the NFT  "--"
    function listItem (address nftAddress, uint256 tokenId, uint256 price) external 
      alreadyListed(nftAddress, tokenId, msg.sender) 
      isOwner(nftAddress, tokenId, msg.sender)
      {
        if (price <= 0) {
            revert NftMarketPlace__PriceMustBeAboveZero();
        }
        //There are 2 ways for artists/ownners to list NFTs:
        // 1. Artists can send their NFT to market. Now the MarketPlace "holds" their NFT
        // 2. Artists hold their NFT and give market-place their approval to sell the NFT for them

        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) { //checks if this contract is allowed to manage the assets of the owner
            revert NftMarketPlace__NftNotApprovedForListing();
        } 
        //{ function getApproved(tokenId) returns(address operator) } returns if the `operator` is allowed to manage all of the assets of `owner`.
        //address(this) => the address of this contract (ie. NftMarketPlace)
        //Operator: can call transfer function for any token owned by the caller.
        //The caller must own the token or be an approved operator

        s_listings[nftAddress][tokenId] = Listing(price, msg.sender); //emit event when state variables are updated
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyItem (address nftAddress, uint256 tokenId) external payable 
      nonReentrant
      isListed(nftAddress, tokenId)
    {
        Listing memory listedItem = s_listings[nftAddress][tokenId];

        if (msg.value < listedItem.price) {
            revert NftMarketPlace__PriceNotEnough(nftAddress, tokenId, listedItem.price);
        }

        // Sending the money to user is a bad idea
        // users should withdraw the money
        s_proceeds[listedItem.seller] = s_proceeds[listedItem.seller] + msg.value;
        delete (s_listings[nftAddress][tokenId]); //Now, we have bought the item. So, we'll delete the item from listings
        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId); // transferring the NFT
        emit ItemBought(msg.sender, nftAddress, tokenId, listedItem.price);

        //To avoid Re-entrancy-attack: always transfer after updating the state variable 
        //24:10:00
    }

    // Only the nft owner can cancel the listing
    //Only the listed item can be canceled (ofc)
    function cancelListing (address nftAddress, uint256 tokenId) external 
        isOwner (nftAddress, tokenId, msg.sender) 
        isListed (nftAddress, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemCanceled(msg.sender, nftAddress, tokenId);
    }

    function updateListing (address nftAddress, uint256 tokenId, uint256 newPrice) external 
        isOwner (nftAddress, tokenId, msg.sender) 
        isListed (nftAddress, tokenId)
    {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        listedItem.price = newPrice; 
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice); //updating listing is like re-listing, so we didn't create a new event
    }

    function withdrawProceeds() external 
    {
        uint256 proceeds = s_proceeds[msg.sender]; 
        if (proceeds <= 0) {
            revert NftMarketPlace__NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{ value: proceeds }("");
        if (!success) {
            revert NftMarketPlace__TransferFailed();
        }
    }

    function getListing (address nftAddress, uint256 tokenId) external view returns (Listing memory)
    {
        return s_listings[nftAddress][tokenId];
    } 

    function getProceeds (address seller) external view returns (uint256)
    {
        return s_proceeds[seller];
    }
}


