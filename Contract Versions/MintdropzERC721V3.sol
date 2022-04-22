// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract MintdropzERC721V3 is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;

    string public MINTDROPZ_PROVENANCE; // IPFS URL WILL BE ADDED WHEN MINTDROPZ ARE ALL SOLD OUT
    string public LICENSE_TEXT; // IT IS WHAT IT SAYS

    bool licenseLocked; // TEAM CAN'T EDIT THE LICENSE AFTER THIS GETS TRUE

    uint256 public maxMintdropzPurchase;
    uint256 public MAX_MINTDROPZ;
    uint256 public mintdropzPrice; // each token price is 0.03 ETH

    address public royaltyReceiver;
    uint256 public royaltyPercent;
    uint256 public DENOMINATOR;

    bool public saleIsActive;

    mapping(uint256 => string) public mintdropzNames;
    uint256 public mintdropzReserve; // Reserve 125

    // baseURI
    string public baseURI;

    // FreeMint
    bytes32 merkleTreeRoot;
    uint256 public freeMintAmount;
    uint256 public maxFreeMintCnt;
    uint256 public freeMintedCnt;
    mapping(address => uint256) private claimFreeCnt;

    event MintdropzNameChange(address _by, uint256 _tokenId, string _name);
    event LicenseisLocked(string _licenseText);

    function initialize(
        uint256 _maxMintdropzPurchase,
        uint256 _MAX_MINTDROPZ,
        uint256 _mintdropzPrice,
        uint256 _DENOMINATOR,
        uint256 _mintdropzReserve,
        address _royaltyReceiver,
        uint256 _royaltyPercent,
        uint256 _freeMintAmount,
        uint256 _maxFreeMintCnt
    ) public initializer {
        require(_royaltyPercent >= 100 && _royaltyPercent < 10000, "Invalid");
        __ERC721_init("Mintdropzz", "MD");
        __Ownable_init();
        __ReentrancyGuard_init();

        MINTDROPZ_PROVENANCE = "";
        LICENSE_TEXT = "";
        licenseLocked = false;
        saleIsActive = true;

        maxMintdropzPurchase = _maxMintdropzPurchase; // 20
        MAX_MINTDROPZ = _MAX_MINTDROPZ; // 10000
        mintdropzPrice = _mintdropzPrice; // 30000000000000000
        DENOMINATOR = _DENOMINATOR; // 10000
        mintdropzReserve = _mintdropzReserve; // 125

        freeMintAmount = _freeMintAmount; // 500
        maxFreeMintCnt = _maxFreeMintCnt; // 3

        royaltyReceiver = _royaltyReceiver;
        royaltyPercent = _royaltyPercent;
    }

    function reserveMintdropz(address _to, uint256 _reserveAmount)
        external
        onlyOwner
    {
        require(
            _reserveAmount > 0 && _reserveAmount <= mintdropzReserve,
            "Not enough reserve left for team"
        );
        mintdropzReserve = mintdropzReserve.sub(_reserveAmount);
        uint256 supply = totalSupply();
        for (uint256 i = 1; i <= _reserveAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    function setProvenanceHash(string memory provenanceHash)
        external
        onlyOwner
    {
        MINTDROPZ_PROVENANCE = provenanceHash;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function changeRoyaltyReceiver(address _newReceiver) external onlyOwner {
        require(_newReceiver != address(0), "Invalid address");
        royaltyReceiver = _newReceiver;
    }

    function changeRoyaltyPercent(uint256 _newRoyalty) external onlyOwner {
        require(_newRoyalty >= 100 && _newRoyalty < 10000, "Invalid");
        royaltyPercent = _newRoyalty;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
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
    function tokenLicense(uint256 _id) external view returns (string memory) {
        require(_id < totalSupply(), "CHOOSE A MINTDROPZ WITHIN RANGE");
        return LICENSE_TEXT;
    }

    // Locks the license to prevent further changes
    function lockLicense() external onlyOwner {
        licenseLocked = true;
        emit LicenseisLocked(LICENSE_TEXT);
    }

    // Change the license
    function changeLicense(string memory _license) external onlyOwner {
        require(!licenseLocked, "License already locked");
        LICENSE_TEXT = _license;
    }

    function setMerkleTree(bytes32 _merkleTreeRoot) external onlyOwner {
        merkleTreeRoot = _merkleTreeRoot;
    }

    function freeMint() external payable {
        require(saleIsActive, "Sale must be active to mint nft");
        require(
            totalSupply() < MAX_MINTDROPZ,
            "Exceed max supply of Mintdropz"
        );
        uint256 royaltyFee = mintdropzPrice.mul(royaltyPercent).div(
            DENOMINATOR
        );
        uint256 restAmount = msg.value - royaltyFee;
        if (freeMintedCnt < freeMintAmount) {
            require(
                claimFreeCnt[msg.sender] < maxFreeMintCnt,
                "One user can min max 10 times for free"
            );
            require(msg.value >= royaltyFee, "Not enough pay");
            freeMintedCnt++;
            claimFreeCnt[msg.sender]++;
        } else {
            require(
                msg.value >= mintdropzPrice.add(royaltyFee),
                "You should pay 0.03 eth to mint"
            );
            restAmount = restAmount - mintdropzPrice;
        }
        payable(msg.sender).transfer(restAmount);
        payable(royaltyReceiver).transfer(royaltyFee);
        payable(owner()).transfer(address(this).balance);
        _safeMint(msg.sender, totalSupply().add(1));
    }

    function mintNFT(uint256 numberOfTokens) external payable nonReentrant {
        require(saleIsActive, "Sale must be active to mint nft");
        require(
            numberOfTokens > 0 && numberOfTokens <= maxMintdropzPurchase,
            "Can only mint 20 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_MINTDROPZ,
            "Exceed max supply of Mintdropz"
        );
        uint256 royaltyFee = mintdropzPrice
            .mul(numberOfTokens)
            .mul(royaltyPercent)
            .div(DENOMINATOR);
        require(
            msg.value >= mintdropzPrice.mul(numberOfTokens).add(royaltyFee),
            "Invalid amount"
        );

        uint256 restAmount = msg.value
            .sub(mintdropzPrice.mul(numberOfTokens))
            .sub(royaltyFee);
        payable(msg.sender).transfer(restAmount);
        payable(royaltyReceiver).transfer(royaltyFee);
        payable(owner()).transfer(address(this).balance);

        uint256 mintIndex = totalSupply();
        for (uint256 i = 1; i <= numberOfTokens; i++) {
            _safeMint(msg.sender, mintIndex + i);
        }
    }

    function changeMintdropzName(uint256 _tokenId, string memory _name)
        external
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "Hey, your wallet doesn't own this mintdropz!"
        );
        require(
            sha256(bytes(_name)) != sha256(bytes(mintdropzNames[_tokenId])),
            "New name is same as the current one"
        );
        mintdropzNames[_tokenId] = _name;

        emit MintdropzNameChange(msg.sender, _tokenId, _name);
    }

    function viewMintdropzName(uint256 _tokenId)
        external
        view
        returns (string memory)
    {
        require(_tokenId < totalSupply(), "Choose a mintdropz within range");
        return mintdropzNames[_tokenId];
    }

    // GET ALL MINTDROPZ OF A WALLET AS AN ARRAY OF STRINGS. WOULD BE BETTER MAYBE IF IT RETURNED A STRUCT WITH ID-NAME MATCH
    function mintdropzNamesOfOwner(address _owner)
        external
        view
        returns (string[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new string[](0);
        } else {
            string[] memory result = new string[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = mintdropzNames[
                    tokenOfOwnerByIndex(_owner, index)
                ];
            }
            return result;
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

        function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
