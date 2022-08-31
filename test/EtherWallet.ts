import { expect } from "chai";
import { ethers } from "hardhat";

describe("EtherWallet", function () {
  it("deposit & withdraw", async function () {
    const EtherWallet = await ethers.getContractFactory("EtherWallet");
    let etherWallet = await EtherWallet.deploy();
    await etherWallet.deployed();
    const [deployer, account1] = await ethers.getSigners();

    const preBalance = await deployer.getBalance();
    const depositAmount = ethers.utils.parseEther("1");
    await etherWallet.deposit({ value: depositAmount });
    const afterBalance = await deployer.getBalance();
    expect(afterBalance).to.lt(preBalance.sub(depositAmount));
    expect(await etherWallet.balanceOf(deployer.address)).to.eq(depositAmount);

    const acc1BalanceBefore = await account1.getBalance();
    await etherWallet.withdraw(account1.address, depositAmount);
    expect(await account1.getBalance()).to.eq(
      acc1BalanceBefore.add(depositAmount)
    );
    expect(await etherWallet.balanceOf(deployer.address)).to.eq(0);

    etherWallet = await etherWallet.connect(account1);
    await etherWallet.deposit({
      value: depositAmount,
    });
    expect(await etherWallet.balanceOf(account1.address)).to.eq(depositAmount);
  });
});
