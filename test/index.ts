import { expect } from "chai";
import { ethers } from "hardhat";

describe("Loan Shark", function () {
  let token, loanshark, account0;

  this.beforeAll(async function () {
    [account0] = await ethers.getSigners()

    const TokenFactory = await ethers.getContractFactory('SharkToken')
    token = await TokenFactory.deploy()

    const SharkFactory = await ethers.getContractFactory('LoanShark')
    loanshark = await SharkFactory.deploy(token.address, 1, 0)
    token.approve(loanshark.address, ethers.constants.MaxUint256)
  })


});
