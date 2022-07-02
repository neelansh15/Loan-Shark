// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SharkToken is ERC20 {
    constructor() ERC20("SharkToken", "SHARK") {
        _mint(msg.sender, 100000 * 10**18);
    }
}
