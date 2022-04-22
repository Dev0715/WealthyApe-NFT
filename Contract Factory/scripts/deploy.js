const { BigNumber } = require("@ethersproject/bignumber");
const { ethers, upgrades } = require("hardhat");

async function main() {
  // Deploy upgradable Mintdropz ERC721 contract
  const MintdropzERC721 = await ethers.getContractFactory("MintdropzERC721V2");

  const mintdropzPrice = BigNumber.from((0.03*10**18).toString()); // 30000000000000000

  const upgradesMintdropzERC721 = await upgrades.deployProxy(
    MintdropzERC721,
    [
      20, // maxMintdropzPurchase
      10000, // MAX_MINTDROPZ
      mintdropzPrice, // mintdropzPrice
      10000, // DENOMINATOR
      125, // mintdropzReserve
      "0x7D686Ff7a4d436Ed10675A7F0E83Fd41477b0717", // royaltyReceiver address
      500, // royaltyPercent
      500, // Free Minting of 500 times are available
      3 // Max free minting count for one user
    ]
  );

  await upgradesMintdropzERC721.deployed();
  console.log("Mintdropz ERC721 token deployed to address: ", upgradesMintdropzERC721.address);
  await upgradesMintdropzERC721.setBaseURI(`https://soprano-backend.herokuapp.com/temp/metadata/token/`);
  const baseURI = await upgradesMintdropzERC721.baseURI();
  console.log('baseURI: ', baseURI);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
      console.error(error);
      process.exit(1);
  });
