// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
    Supply ether as collateral to receive stablecoin as loan for a fee and pay back anytime.
 */
contract LoanShark is Ownable {
    address public stablecoin;
    IERC20 private token;

    // Fees in Ether
    uint256 public fee;
    uint256 public collectedFees;

    // Ratio of Stablecoin-ETH. If Ratio = 2 => Get 2 * x Stablecoins for x Ether
    uint8 public ratio;

    event SetFee(uint256 oldFee, uint256 newFee, address indexed owner);
    event SetStablecoin(
        address oldStablecoin,
        address newStablecoin,
        address indexed owner
    );
    event Borrow(address indexed borrower, uint256 amount, uint256 timestamp);
    event Repay(address indexed borrower, uint256 amount, uint256 timestamp);

    constructor(
        address _stablecoin,
        uint8 _ratio,
        uint256 _fee
    ) {
        stablecoin = _stablecoin;
        token = IERC20(token);
        ratio = _ratio;
        fee = _fee;
    }

    // Owner specific functions
    function withdraw() external onlyOwner {
        uint256 amount = collectedFees;
        collectedFees = 0;

        payable(owner()).transfer(amount);
    }

    function setFee(uint256 _fee) external onlyOwner {
        emit SetFee(fee, _fee, msg.sender);
        fee = _fee;
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        emit SetStablecoin(stablecoin, _stablecoin, msg.sender);
        stablecoin = _stablecoin;
        token = IERC20(_stablecoin);
    }

    // Main functions
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function borrow() external payable {
        uint256 amount = msg.value;
        uint256 balance = token.balanceOf(address(this));
        require(amount > 0 && amount < balance, "Cannot process amount");

        token.transfer(msg.sender, amount * ratio);

        emit Borrow(msg.sender, amount, block.timestamp);
    }

    function repay(uint256 _amount) external {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient Balance");

        collectedFees += fee;

        token.transferFrom(msg.sender, address(this), _amount);
        payable(msg.sender).transfer((_amount / ratio) - fee);

        emit Repay(msg.sender, _amount, block.timestamp);
    }
}
