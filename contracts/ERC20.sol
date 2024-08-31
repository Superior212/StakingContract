// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC is ERC20 {
    address public owner;

    constructor() ERC20("ERC Token", "USDT") {
        owner = msg.sender;
        _mint(msg.sender, 100000e18);
    }

    function mint(uint256 _amount) external {
        require(msg.sender == owner, "you are not owner");
        _mint(msg.sender, _amount * 1e18);
    }
}
