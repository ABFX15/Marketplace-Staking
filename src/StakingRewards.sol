// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {NFTCollection} from "./NFTCollection.sol";
import {ERC20Token} from "./ERC20Token.sol";

contract StakingRewards is IERC721Receiver, Ownable {
    error StakingRewards__NotOwnerOfNFT();

    IERC721 public immutable i_nftCollection;
    ERC20Token public rewardToken;

    uint256 public constant REWARD_RATE = 80; // 80%
    uint256 public constant TIME_UNIT = 1 days; // 1 day

    struct DepositStruct {
        address originalOwner;
        uint256 depositTime;
    }

    mapping(uint256 => DepositStruct) public s_deposits;

    event NFTDeposited(address indexed originalOwner, uint256 indexed tokenId);

    constructor(address _nftCollectionAddress) Ownable(msg.sender) {
        i_nftCollection = IERC721(_nftCollectionAddress);
    }

    function calculateReward(uint256 depositTimestamp) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - depositTimestamp;
        uint256 rewardCalculated = timeElapsed * REWARD_RATE / TIME_UNIT;
        return rewardCalculated;
    }

    function depositNFT(uint256 tokenId) external {
        if (i_nftCollection.ownerOf(tokenId) != msg.sender) revert StakingRewards__NotOwnerOfNFT();
        s_deposits[tokenId] = DepositStruct({originalOwner: msg.sender, depositTime: block.timestamp});
        i_nftCollection.transferFrom(msg.sender, address(this), tokenId);

        emit NFTDeposited(msg.sender, tokenId);
    }

    function getRewards(uint256 tokenId) external {
        DepositStruct memory deposit = s_deposits[tokenId];
        if (deposit.originalOwner != msg.sender) revert StakingRewards__NotOwnerOfNFT();
        uint256 rewardToClaim = calculateReward(deposit.depositTime);
        deposit.depositTime = block.timestamp;
        s_deposits[tokenId] = deposit;
        rewardToken.mint(_msgSender(), rewardToClaim);
    }

    function withdrawNFT(uint256 tokenId) external {
        DepositStruct memory deposit = s_deposits[tokenId];
        if (deposit.originalOwner != msg.sender) revert StakingRewards__NotOwnerOfNFT();
        uint256 rewardToClaim = calculateReward(deposit.depositTime);
        i_nftCollection.safeTransferFrom(address(this), msg.sender, tokenId);
        rewardToken.mint(_msgSender(), rewardToClaim);
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setRewardToken(address _rewardTokenAddress) external onlyOwner {
        rewardToken = ERC20Token(_rewardTokenAddress);
    }
}
