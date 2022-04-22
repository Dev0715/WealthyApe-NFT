const { BigNumber } = require("@ethersproject/bignumber");
const { ethers, upgrades } = require("hardhat");

async function main_factory() {
    // We get the contract to deploy
    const Factory = await ethers.getContractFactory("ERC721Factory");
    const factory = await Factory.deploy();

    console.log("Factory deployed to:", factory.address);
}

async function main_v1() {
    // We get the contract to deploy
    const Factory = await ethers.getContractFactory("MintdropzERC721");
    const factory = await Factory.deploy("0xeEb6d6383c7C2065356F10842b71eE5F96D95CEc", 500, 10000);

    console.log("Factory deployed to:", factory.address);
}

async function main_v3() {
    const MintdropzV3 = await ethers.getContractFactory("MintdropzERC721V3");

    const mintdropzPrice = BigNumber.from((0.03 * 10 ** 18).toString()); // 30000000000000000
    console.log(mintdropzPrice);

    const upgradesMintdropzV3 = await upgrades.deployProxy(MintdropzV3, [
        20, // maxMintdropzPurchase
        10000, // MAX_MINTDROPZ
        mintdropzPrice, // mintdropzPrice
        10000, // DENOMINATOR
        125, // mintdropzReserve
        "0xeEb6d6383c7C2065356F10842b71eE5F96D95CEc", // royaltyReceiver address
        500, // royaltyPercent
        500, // Free Minting of 500 times are available
        10 // Max free minting count for one user
    ]);

    await upgradesMintdropzV3.deployed();
    upgradesMintdropzV3.setBaseURI('https://apes-backend.herokuapp.com/temp/metadata/token');

    const _mintdropzPrice = await upgradesMintdropzV3.mintdropzPrice();
    console.log(_mintdropzPrice);

    console.log("MintdropzV3 deployed to:", upgradesMintdropzV3.address);
}

async function main_v4() {
    const MintdropzV4 = await ethers.getContractFactory("MintdropzERC721V4");

    const mintdropzPrice = BigNumber.from((0.03 * 10 ** 18).toString()); // 30000000000000000
    console.log(mintdropzPrice);

    const upgradesMintdropzV4 = await upgrades.deployProxy(MintdropzV4, [
        6666, // MAX_MINTDROPZ
        mintdropzPrice, // mintdropzPrice
        10000, // DENOMINATOR
        125, // mintdropzReserve
        "0xeEb6d6383c7C2065356F10842b71eE5F96D95CEc", // royaltyReceiver address
        500, // royaltyPercent
        1666 // Free Minting of 1666 times are available
    ]);

    await upgradesMintdropzV4.deployed();
    upgradesMintdropzV4.setBaseURI('https://apes-backend.herokuapp.com/temp/metadata/token');

    const _mintdropzPrice = await upgradesMintdropzV4.mintdropzPrice();
    console.log(_mintdropzPrice);

    console.log("MintdropzV4 deployed to:", upgradesMintdropzV4.address);
}

async function main_wealthy() {
    const WealthyApes = await ethers.getContractFactory("WealthyApesERC721");

    const wealthyApesPrice = BigNumber.from((0.03 * 10 ** 18).toString()); // 30000000000000000

    const wealthyApes = await upgrades.deployProxy(WealthyApes, [
        6666, // MAX_MINTDROPZ
        wealthyApesPrice, // mintdropzPrice
        10000, // DENOMINATOR
        125, // mintdropzReserve
        "0xeEb6d6383c7C2065356F10842b71eE5F96D95CEc", // royaltyReceiver address
        500, // royaltyPercent
        999 // Free Minting of 1666 times are available
    ]);

    await wealthyApes.deployed();
    wealthyApes.setBaseURI('https://apes-backend.herokuapp.com/temp/metadata/token');

    console.log("WealthyApes deployed to:", wealthyApes.address);
}