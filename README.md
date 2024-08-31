# Staking and ERC20 Token Contracts

This repository contains two main smart contracts:

1. **ERC20 Token Contract**: A standard ERC20 token implementation using OpenZeppelin's ERC20 contract.
2. **Staking Contract**: A staking contract that allows users to stake the ERC20 token and earn rewards based on the staking duration.

## deploy link

ERC20TokenModule#ERC - 0xEC824d6122f5D63A41Cb6AB8839362f342e2b35F
StakeERC20Module#StakeERC20 - 0x557CB58e6894F96931beA245D6d1Abd22844C439

https://sepolia-blockscout.lisk.com/address/0x557CB58e6894F96931beA245D6d1Abd22844C439#code

## Table of Contents

- [Staking and ERC20 Token Contracts](#staking-and-erc20-token-contracts)
  - [deploy link](#deploy-link)
  - [Table of Contents](#table-of-contents)
  - [Contracts Overview](#contracts-overview)
    - [ERC20 Token Contract](#erc20-token-contract)
    - [Staking Contract](#staking-contract)
  - [Installation](#installation)
  - [Deployment](#deployment)
    - [Deploying the ERC20 Token](#deploying-the-erc20-token)
    - [Deploying the Staking Contract](#deploying-the-staking-contract)
  - [Verification](#verification)
  - [Interacting with the Contracts](#interacting-with-the-contracts)
    - [Minting Tokens](#minting-tokens)
    - [Staking Tokens](#staking-tokens)
    - [Claiming Rewards](#claiming-rewards)
  - [License](#license)

## Contracts Overview

### ERC20 Token Contract

This contract implements a standard ERC20 token using OpenZeppelin's ERC20 implementation. The token is initialized with a name, symbol, and an initial supply that is minted to the owner's address upon deployment.

- **Contract Name**: `ERC`
- **Constructor Parameters**:
  - `string memory name`: The name of the token.
  - `string memory symbol`: The symbol of the token.
  - `uint256 initialSupply`: The initial supply of tokens, minted to the deployer's address.

### Staking Contract

The staking contract allows users to stake the ERC20 token and earn rewards. The rewards are based on a fixed annual interest rate, and the staking period can be customized by the user.

- **Contract Name**: `StakeERC20`
- **Constructor Parameters**:
  - `IERC20 stakingTokenAddress`: The address of the ERC20 token to be staked.

## Installation

To work with these contracts locally, you'll need to have [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) installed. Then, clone the repository and install the dependencies:

```bash
git clone https://github.com/Superior212/StakingContract
cd staking-contracts
npm install
```

## Deployment

### Deploying the ERC20 Token

To deploy the ERC20 token, use the Hardhat Ignition module:

1. Edit the `ignition/modules/ERC20.ts` script if necessary.
2. Deploy the token:

   ```bash
   npx hardhat ignition deploy ./ignition/modules/ERC20.ts --network lisk-sepolia
   ```

   After deployment, note the token's contract address.

### Deploying the Staking Contract

To deploy the staking contract:

1. Edit the `ignition/modules/StakeERC20.ts` script to include the deployed ERC20 token's address.
2. Deploy the staking contract:

   ```bash
   npx hardhat ignition deploy ./ignition/modules/StakeERC20.ts --network lisk-sepolia
   ```

   After deployment, note the staking contract's address.

## Verification

To verify the contracts on Etherscan:

1. **ERC20 Token**:

   ```bash
   npx hardhat verify --network lisk-sepolia <ERC20_CONTRACT_ADDRESS> "<TOKEN_NAME>" "<TOKEN_SYMBOL>" "<INITIAL_SUPPLY>"
   ```

2. **Staking Contract**:

   ```bash
   npx hardhat verify --network lisk-sepolia <STAKING_CONTRACT_ADDRESS> "<STAKING_TOKEN_ADDRESS>"
   ```

Replace `<ERC20_CONTRACT_ADDRESS>`, `<TOKEN_NAME>`, `<TOKEN_SYMBOL>`, `<INITIAL_SUPPLY>`, `<STAKING_CONTRACT_ADDRESS>`, and `<STAKING_TOKEN_ADDRESS>` with the appropriate values.

## Interacting with the Contracts

### Minting Tokens

If you are the owner, you can mint additional tokens:

```solidity
function mint(uint256 _amount) external onlyOwner;
```

### Staking Tokens

To stake tokens, use the `stake` function:

```solidity
function stake(uint256 amount, uint256 durationInSeconds) external;
```

### Claiming Rewards

After the staking period has ended, you can claim your rewards:

```solidity
function claimReward(uint256 _index) external;
```

## License

This project is licensed under the MIT License.
