# Mintdropz

## Installation

`npm i`

## Compile/build contracts

`npm run build`

## Deployment

- Deploy to Ethereum testnet: `npm run deploy-ethereum-testnet`
- Deploy to Ethereum mainnet: `npm run deploy-ethereum-mainnet`
- Deploy to Polygon testnet: `npm run deploy-polygon-testnet`
- Deploy to Polygon mainnet: `npm run deploy-polygon-mainnet`
- Deploy to Celo testnet: `npm run deploy-celo-testnet`
- Deploy to Celo mainnet: `npm run deploy-celo-mainnet`

## Verify

- Rinkeby contract:

`npx hardhat verify --network rinkeby $newDeployAddress`
### Example
- MintdropzERC721 contract:
`npx hardhat verify --network rinkeby 0x7D46df69013b4D19Bf83B546Ce5F0a7109310294`
- MintdropzERC20 contract:
`npx hardhat verify --network rinkeby 0x4Cf585eAf4b86844AA8054037Ca94d6D58d73F55 1000000000000000000000000`
- Auction contract:
`npx hardhat verify --network rinkeby 0x8008fAd0197F6145f4b2e9F38B0C920E655BfC90 0x7D46df69013b4D19Bf83B546Ce5F0a7109310294 0x4Cf585eAf4b86844AA8054037Ca94d6D58d73F55 250 0xA6431D80240C3a3FeF54Dd2179b2BDC13fEec467`

- Polygon contract:

`npx hardhat verify --constructor-args deploy_args_mintdropz.js --network matictestnet $newDeployAddress`

- Celo contract:

``
