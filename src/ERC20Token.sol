// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IGameToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract ERC20Token is ERC20, IGameToken {
    error ERC20Token__NotStakingRewardContract();
    error ERC20Token__MustBeMsgSender();

    address public immutable i_stakingRewardContract;

    constructor(string memory _name, string memory _symbol, address _stakingRewardContract) ERC20(_name, _symbol) {
        i_stakingRewardContract = _stakingRewardContract;
    }

    function mint(address to, uint256 amount) external {
        if (msg.sender != i_stakingRewardContract) revert ERC20Token__NotStakingRewardContract();
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        if (from != msg.sender) revert ERC20Token__MustBeMsgSender();
        _burn(from, amount);
    }
}
