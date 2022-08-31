import { ethers } from "hardhat";

async function main() {
  const [deployer, toAccount] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  // const Token = await ethers.getContractFactory("Token");
  // const token = await Token.deploy();

  // console.log("Token address:", token.address);
  // console.log("Balance of:", await token.balanceOf(deployer.address));
  // await token.connect(deployer).transfer(toAccount.address, 1000);
  // console.log({
  //   "deployer balance": await token.balanceOf(deployer.address),
  //   "target account balance": await token.balanceOf(toAccount.address),
  // });

  const EtherWallet = await ethers.getContractFactory("EtherWallet");
  const etherWallet = await EtherWallet.deploy();

  console.log("Contract address:", etherWallet.address);
  console.log("Tx hash:", etherWallet.deployTransaction.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
