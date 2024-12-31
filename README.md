# NFT Staking DApp

A decentralized application (DApp) that allows users to stake NFTs and earn ERC20 token rewards.

## Overview

This project implements an NFT staking system with the following key components:

- `NFTCollection.sol`: An ERC721 NFT collection contract that allows minting of NFTs
- `ERC20Token.sol`: A reward token contract that implements the ERC20 standard
- `StakingRewards.sol`: The main staking contract that handles NFT deposits and reward distribution

## Core Features

### NFT Collection
- Mint NFTs by paying ETH
- Configurable max supply
- Withdrawable mint proceeds by owner
- Base URI for token metadata

### Reward Token
- Custom ERC20 token for staking rewards
- Minting restricted to staking contract
- Burn functionality for token holders

### Staking System
- Stake NFTs to earn rewards
- Reward rate of 80% per day
- Claim rewards without unstaking
- Withdraw NFTs and claim pending rewards
- Owner can set reward token address

## Contract Interactions

1. Users mint NFTs from the NFTCollection contract
2. Users approve the StakingRewards contract to transfer their NFTs
3. Users stake NFTs to start earning rewards
4. Users can:
   - Claim rewards while keeping NFTs staked
   - Withdraw NFTs and claim accumulated rewards

## Technical Details

- Solidity version: 0.8.28
- Built with OpenZeppelin contracts
- Uses safe transfer mechanisms for NFTs
- Implements IERC721Receiver for safe NFT handling

## Security Features

- Ownership checks for NFT operations
- Access control for admin functions
- Safe math operations
- Reentrancy protection via OpenZeppelin

## Setup and Deployment

1. Deploy NFTCollection contract
2. Deploy StakingRewards contract with NFTCollection address
3. Deploy ERC20Token contract with StakingRewards address
4. Call setRewardToken on StakingRewards with ERC20Token address

## License

This project is licensed under the MIT License.
