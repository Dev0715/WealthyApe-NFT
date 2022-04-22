// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MintdropzERC721 is Ownable, ReentrancyGuard, ERC721Enumerable {
    using SafeMath for uint256;

    string public MINTDROPZ_PROVENANCE = ""; // IPFS URL WILL BE ADDED WHEN MINTDROPZ ARE ALL SOLD OUT
    string public LICENSE_TEXT = ""; // IT IS WHAT IT SAYS

    bool licenseLocked = false; // TEAM CAN'T EDIT THE LICENSE AFTER THIS GETS TRUE

    uint256 public constant maxMintdropzPurchase = 20;

    uint256 public constant MAX_MINTDROPZ = 10000;

    uint256 public mintdropzPrice = 30000000000000000; // each token price is 0.03 ETH
    address public royaltyReceiver;
    uint256 public royaltyPercent;
    uint256 public DENOMINATOR;

    bool public saleIsActive = true;

    mapping(uint256 => string) public mintdropzNames;

    // Reserve 125 Mintdropz for team - Giveaways/Prizes etc
    uint256 public mintdropzReserve = 125;

    // baseURI
    string public baseURI;

    event MintdropzNameChange(address _by, uint256 _tokenId, string _name);

    event LicenseisLocked(string _licenseText);

    constructor(
        address _royaltyReceiver,
        uint256 _royaltyPercent,
        uint256 _DENOMINATOR
    ) ERC721("Mintdropzz", "MD") {
        royaltyReceiver = _royaltyReceiver;
        royaltyPercent = _royaltyPercent;
        DENOMINATOR = _DENOMINATOR;
    }

    function reserveMintdropz(address _to, uint256 _reserveAmount) public onlyOwner {        
        require(_reserveAmount > 0 && _reserveAmount <= mintdropzReserve, "Not enough reserve left for team");
        mintdropzReserve = mintdropzReserve.sub(_reserveAmount);
        uint256 supply = totalSupply();
        for (uint i = 0; i < _reserveAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        MINTDROPZ_PROVENANCE = provenanceHash;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    // Returns the license for tokens
    function tokenLicense(uint256 _id) public view returns(string memory) {
        require(_id < totalSupply(), "CHOOSE A MINTDROPZ WITHIN RANGE");
        return LICENSE_TEXT;
    }
    
    // Locks the license to prevent further changes 
    function lockLicense() public onlyOwner {
        licenseLocked =  true;
        emit LicenseisLocked(LICENSE_TEXT);
    }
    
    // Change the license
    function changeLicense(string memory _license) public onlyOwner {
        require(!licenseLocked, "License already locked");
        LICENSE_TEXT = _license;
    }

    function mintNFT(uint256 numberOfTokens) public payable nonReentrant {
        require(saleIsActive, "Sale must be active to mint nft");
        require(numberOfTokens > 0 && numberOfTokens <= maxMintdropzPurchase, "Can only mint 20 tokens at a time");
        require(totalSupply().add(numberOfTokens) <= MAX_MINTDROPZ, "Exceed max supply of Mintdropz");
        uint256 royaltyFee = mintdropzPrice.mul(numberOfTokens).mul(royaltyPercent).div(DENOMINATOR);
        require(msg.value >= mintdropzPrice.mul(numberOfTokens).add(royaltyFee), "Invalid amount");

        uint256 restAmount = msg.value.sub(mintdropzPrice.mul(numberOfTokens)).sub(royaltyFee);
        payable(msg.sender).transfer(restAmount);
        payable(royaltyReceiver).transfer(royaltyFee);
        payable(owner()).transfer(address(this).balance);

        uint256 mintIndex = totalSupply();
        for(uint i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, mintIndex + i);
        }
    }

    function changeMintdropzName(uint256 _tokenId, string memory _name) public {
        require(ownerOf(_tokenId) == msg.sender, "Hey, your wallet doesn't own this mintdropz!");
        require(sha256(bytes(_name)) != sha256(bytes(mintdropzNames[_tokenId])), "New name is same as the current one");
        mintdropzNames[_tokenId] = _name;
        
        emit MintdropzNameChange(msg.sender, _tokenId, _name);     
    }

    function viewMintdropzName(uint256 _tokenId) public view returns( string memory ){
        require( _tokenId < totalSupply(), "Choose a mintdropz within range" );
        return mintdropzNames[_tokenId];
    }

    // GET ALL MINTDROPZ OF A WALLET AS AN ARRAY OF STRINGS. WOULD BE BETTER MAYBE IF IT RETURNED A STRUCT WITH ID-NAME MATCH
    function mintdropzNamesOfOwner(address _owner) external view returns(string[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new string[](0);
        } else {
            string[] memory result = new string[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = mintdropzNames[ tokenOfOwnerByIndex(_owner, index) ] ;
            }
            return result;
        }
    }
}
