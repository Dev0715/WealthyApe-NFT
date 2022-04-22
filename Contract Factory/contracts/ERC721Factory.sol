// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma abicoder v2;

import './ERC721Contract.sol';

contract ERC721Factory {
    mapping(address => address) public contractAddresses;
    uint256 public contractCount;

    function createContract(
        string memory _name,
        string memory _symbol,
        address _royaltyReceiver,
        uint256 _royaltyPercent,
        uint256 _tokenPrice,
        uint256 _DENOMINATOR
    ) public {
        contractAddresses[msg.sender] = address(new ERC721Contract(msg.sender, _name, _symbol, _royaltyReceiver, _royaltyPercent, _tokenPrice, _DENOMINATOR));
        contractCount++;
    }

    function getMyContract(address _address) external view returns (address) {
        require (contractAddresses[_address] != address(0));
        return (contractAddresses[_address]);
    }

    function getContractCount() external view returns (uint256) {
        return contractCount;
    }
}
