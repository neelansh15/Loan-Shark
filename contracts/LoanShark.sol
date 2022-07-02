// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LoanShark is Ownable {
    uint256 public fee;
    address public stablecoin;

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function borrow(uint256 _amount) external {

    }
}
