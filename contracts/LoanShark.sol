// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "hardhat/console.sol";

/**
    Supply ether as collateral to receive stablecoin as loan for a fee and pay back anytime.
 */
contract LoanShark is Ownable {
    address public stablecoin;

    // Fees in Ether
    uint256 public fee;
    uint256 public collectedFees;

    // Ratio of Stablecoin-ETH. If Ratio = 2 => Get 2 * x Stablecoins for x Ether
    uint256 public ratio;

    event SetFee(uint256 oldFee, uint256 newFee, address indexed owner);
    event SetStablecoin(
        address oldStablecoin,
        address newStablecoin,
        address indexed owner
    );
    event Borrow(
        address indexed borrower,
        address indexed stablecoin,
        uint256 amount,
        uint256 timestamp
    );
    event Repay(
        address indexed borrower,
        address indexed stablecoin,
        uint256 amount,
        uint256 timestamp
    );

    constructor(
        address _stablecoin,
        uint256 _ratio,
        uint256 _fee
    ) {
        stablecoin = _stablecoin;
        ratio = _ratio;
        fee = _fee;
    }

    // Owner specific functions
    function claimETH() external onlyOwner {
        uint256 amount = collectedFees;
        collectedFees = 0;

        payable(owner()).transfer(amount);
    }

    function claim(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(owner(), _amount);
    }

    function setFee(uint256 _fee) external onlyOwner {
        emit SetFee(fee, _fee, msg.sender);
        fee = _fee;
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        emit SetStablecoin(stablecoin, _stablecoin, msg.sender);
        stablecoin = _stablecoin;
    }

    // Main functions
    function ethBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function borrow() external payable {
        uint256 amount = msg.value;
        IERC20 token = IERC20(stablecoin);
        uint256 balance = token.balanceOf(address(this));

        require(
            amount > 0 && (amount * ratio) / 10**18 <= balance,
            "Cannot process amount"
        );

        token.transfer(msg.sender, (amount * ratio) / 1e18);

        emit Borrow(msg.sender, stablecoin, amount, block.timestamp);
    }

    function repay(uint256 _amount) external {
        uint256 finalAmount = (_amount / (ratio / 10**18)) - fee;

        require(ethBalance() >= finalAmount, "Insufficient ETH Balance");

        collectedFees += fee;

        IERC20 token = IERC20(stablecoin);
        token.transferFrom(msg.sender, address(this), _amount);
        payable(msg.sender).transfer(finalAmount);

        emit Repay(msg.sender, stablecoin, _amount, block.timestamp);
    }
}
