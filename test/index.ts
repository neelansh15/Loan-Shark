import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { formatEther, parseEther } from "ethers/lib/utils";
import { ethers } from "hardhat";
import { ERC20, LoanShark } from "../typechain";

describe("Loan Shark", function () {
  let token: ERC20, loanshark: LoanShark, account0: SignerWithAddress;

  this.beforeAll(async function () {
    [account0] = await ethers.getSigners()

    const TokenFactory = await ethers.getContractFactory('SharkUSDC')
    token = await TokenFactory.deploy()

    await token.deployed()

    const SharkFactory = await ethers.getContractFactory('LoanShark')
    loanshark = await SharkFactory.deploy(token.address, parseEther('1'), 0)

    await loanshark.deployed()

    token.transfer(loanshark.address, parseEther('100000'))
  })

  it("Borrow: Should transfer stablecoin in return for eth", async function () {
    const ratio = +formatEther(await loanshark.ratio())

    const amount = "1"

    // Borrow stablecoin with ETH
    await loanshark.borrow({
      value: parseEther(amount)
    })

    const tokenBalance = +formatEther(await token.balanceOf(account0.address))
    expect(tokenBalance).to.equal(+amount * ratio)
  })

  it("Repay: Should return ETH minus fees when returning stablecoin", async function () {
    const fee = +formatEther(await loanshark.fee())
    const ratio = +formatEther(await loanshark.ratio())

    const amount = "1"

    await token.approve(loanshark.address, ethers.constants.MaxUint256)
    await loanshark.repay(parseEther(amount))

    const finalAmount = ((+amount / ratio) - fee).toString()
    expect(amount).to.eq(finalAmount)
  })
});
