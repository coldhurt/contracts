import { ethers } from 'hardhat'

const WethAddr = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c'

async function main() {
  const [deployer, toAccount, bot, bot1] = await ethers.getSigners()

  console.log(
    'Deploying contracts with the account:',
    deployer.address,
    toAccount.address,
    bot.address,
    bot1.address
  )

  console.log('Account balance:', (await deployer.getBalance()).toString())

  const FlashBot = await ethers.getContractFactory('FlashBot')
  const flashBot = await FlashBot.deploy(WethAddr)

  await flashBot.deployTransaction.wait()
  console.log('Contract address:', flashBot.address)
  console.log('Tx hash:', flashBot.deployTransaction.hash)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
